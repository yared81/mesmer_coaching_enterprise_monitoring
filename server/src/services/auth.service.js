const jwt = require('jsonwebtoken');
const User = require('../models/user.model');
const Institution = require('../models/institution.model');
const Enterprise = require('../models/enterprise.model');

class AuthService {
  /**
   * Login user and return tokens
   */
  async login(email, password) {
    const user = await User.findOne({
      where: { email, is_active: true },
      include: [
        { model: Institution, as: 'institution' },
        { 
          model: Enterprise, 
          as: 'enterpriseAccount',
          include: [{ model: User, as: 'coach', attributes: ['id', 'name', 'email', 'phone'] }]
        }
      ]
    });

    if (!user) {
      throw new Error('Invalid credentials');
    }

    const isMatch = await user.comparePassword(password);
    if (!isMatch) {
      throw new Error('Invalid credentials');
    }

    const { accessToken, refreshToken } = this.generateTokens(user);

    return {
      user: {
        id: user.id,
        email: user.email,
        name: user.name,
        role: user.role,
        institution_id: user.institution_id,
        institution: user.institution ? user.institution.name : null,
        enterprise_id: user.enterpriseAccount ? user.enterpriseAccount.id : null,
        coach: user.enterpriseAccount && user.enterpriseAccount.coach ? {
          id: user.enterpriseAccount.coach.id,
          name: user.enterpriseAccount.coach.name,
          email: user.enterpriseAccount.coach.email,
          phone: user.enterpriseAccount.coach.phone
        } : null
      },
      accessToken,
      refreshToken
    };
  }

  /**
   * Generate JWT Access and Refresh tokens
   */
  generateTokens(user) {
    const accessToken = jwt.sign(
      { 
        id: user.id,
        userId: user.id, 
        role: user.role, 
        institution_id: user.institution_id,
        enterprise_id: user.enterpriseAccount ? user.enterpriseAccount.id : null,
        tokenVersion: user.token_version 
      },
      process.env.JWT_ACCESS_SECRET,
      { expiresIn: process.env.JWT_ACCESS_EXPIRE || '15m' }
    );

    const refreshToken = jwt.sign(
      { userId: user.id },
      process.env.JWT_REFRESH_SECRET,
      { expiresIn: process.env.JWT_REFRESH_EXPIRE || '7d' }
    );

    return { accessToken, refreshToken };
  }

  /**
   * Get current user profile
   */
  async getMe(userId) {
    const user = await User.findByPk(userId, {
      include: [
        { model: Institution, as: 'institution' },
        { 
          model: Enterprise, 
          as: 'enterpriseAccount',
          include: [{ model: User, as: 'coach', attributes: ['id', 'name', 'email', 'phone'] }]
        }
      ],
      attributes: { exclude: ['password_hash'] }
    });

    if (!user) {
      throw new Error('User not found');
    }

    return user;
  }

  /**
   * Update user profile
   */
  async updateProfile(userId, { name, email }) {
    const user = await User.findByPk(userId);
    if (!user) {
      throw new Error('User not found');
    }

    // Check if email is already taken by another user
    if (email && email !== user.email) {
      const existingUser = await User.findOne({ where: { email } });
      if (existingUser) {
        throw new Error('Email already in use');
      }
    }

    if (name) user.name = name;
    if (email) user.email = email;

    await user.save();
    return user;
  }
}

module.exports = new AuthService();
