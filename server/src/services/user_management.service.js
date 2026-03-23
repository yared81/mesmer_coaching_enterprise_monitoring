const { User, Institution, sequelize } = require('../models');
const { Op } = require('sequelize');

class UserManagementService {
  /**
   * Get all users with optional filters
   */
  async getUsers(filters = {}) {
    const { role, institution_id, search } = filters;
    const where = {};

    if (role) where.role = role;
    if (institution_id) where.institution_id = institution_id;
    if (search) {
      where[Op.or] = [
        { name: { [Op.iLike]: `%${search}%` } },
        { email: { [Op.iLike]: `%${search}%` } }
      ];
    }

    const users = await User.findAll({
      where,
      include: [
        { model: Institution, as: 'institution', attributes: ['name'] }
      ],
      attributes: { 
        exclude: ['password_hash'],
        include: role === 'coach' ? [
          [
            sequelize.literal(`(
              SELECT COUNT(*)
              FROM enterprises AS e
              WHERE e.coach_id = "User".id
            )`),
            'enterpriseCount'
          ],
          [
            sequelize.literal(`(
              SELECT COUNT(*)
              FROM coaching_sessions AS s
              WHERE s.coach_id = "User".id
            )`),
            'sessionCount'
          ]
        ] : []
      },
      order: [['created_at', 'DESC']]
    });

    return users;
  }

  /**
   * Create a new user
   */
  async createUser(userData) {
    const { email, password, name, role, institution_id } = userData;

    // Check if user already exists
    const existingUser = await User.findOne({ where: { email } });
    if (existingUser) {
      throw new Error('User with this email already exists');
    }

    const password_hash = await User.hashPassword(password);

    return await User.create({
      email,
      password_hash,
      name,
      role,
      institution_id,
      is_active: true
    });
  }

  /**
   * Update existing user
   */
  async updateUser(userId, userData) {
    const user = await User.findByPk(userId);
    if (!user) {
      throw new Error('User not found');
    }

    const { email, name, role, institution_id, is_active } = userData;

    if (email && email !== user.email) {
      const existingUser = await User.findOne({ where: { email, id: { [Op.ne]: userId } } });
      if (existingUser) {
        throw new Error('Email already in use by another user');
      }
      user.email = email;
    }

    if (name) user.name = name;
    if (role) user.role = role;
    if (institution_id) user.institution_id = institution_id;
    if (is_active !== undefined) user.is_active = is_active;

    await user.save();
    return user;
  }

  /**
   * Toggle user active status
   */
  async toggleUserStatus(userId) {
    const user = await User.findByPk(userId);
    if (!user) {
      throw new Error('User not found');
    }

    user.is_active = !user.is_active;
    await user.save();
    return user;
  }
}

module.exports = new UserManagementService();
