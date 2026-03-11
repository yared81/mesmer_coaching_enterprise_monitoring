const User = require('../models/user.model');
const bcrypt = require('bcryptjs');

class CoachService {
  /**
   * Get all coaches assigned to a specific institution
   */
  async getCoachesByInstitution(institutionId) {
    const coaches = await User.findAll({
      where: {
        institution_id: institutionId,
        role: 'coach',
      },
      attributes: ['id', 'name', 'email', 'is_active', 'created_at'],
      order: [['created_at', 'DESC']],
    });

    // TODO: Later attach stats like 'assignedEnterprisesCount'
    return coaches;
  }

  /**
   * Get details for a specific coach within an institution
   */
  async getCoachDetails(coachId, institutionId) {
    const coach = await User.findOne({
      where: {
        id: coachId,
        institution_id: institutionId,
        role: 'coach',
      },
      attributes: ['id', 'name', 'email', 'is_active', 'created_at'],
    });

    if (!coach) {
      throw new Error('Coach not found or not assigned to your institution');
    }

    return coach;
  }

  /**
   * Register a new coach
   */
  async registerCoach(coachData, institutionId) {
    // Check if email already exists
    const existingUser = await User.findOne({ where: { email: coachData.email } });
    if (existingUser) {
      throw new Error('Email is already registered in the system');
    }

    // Hash the provided default password
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(coachData.password, salt);

    const newCoach = await User.create({
      name: coachData.name,
      email: coachData.email,
      password_hash: hashedPassword,
      role: 'coach',
      institution_id: institutionId,
      is_active: true,
    });

    // Don't return the password hash
    const responseCoach = newCoach.toJSON();
    delete responseCoach.password_hash;
    
    return responseCoach;
  }
}

module.exports = new CoachService();

