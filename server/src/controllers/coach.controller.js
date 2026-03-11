const coachService = require('../services/coach.service');

exports.getCoaches = async (req, res, next) => {
  try {
    const institutionId = req.user.institution_id;
    const coaches = await coachService.getCoachesByInstitution(institutionId);

    res.status(200).json({
      success: true,
      count: coaches.length,
      data: coaches,
    });
  } catch (error) {
    next(error);
  }
};

exports.getCoachDetails = async (req, res, next) => {
  try {
    const institutionId = req.user.institution_id;
    const coachId = req.params.id;
    const coach = await coachService.getCoachDetails(coachId, institutionId);

    res.status(200).json({
      success: true,
      data: coach,
    });
  } catch (error) {
    next(error);
  }
};

exports.registerCoach = async (req, res, next) => {
  try {
    const institutionId = req.user.institution_id;
    
    // In a real app, generate a secure random password and email it.
    // For this demo, we'll accept a password or use a default one.
    const coachData = {
      name: req.body.name,
      email: req.body.email,
      password: req.body.password || 'coach123', 
    };

    const newCoach = await coachService.registerCoach(coachData, institutionId);

    res.status(201).json({
      success: true,
      message: 'Coach registered successfully',
      data: newCoach,
    });
  } catch (error) {
    next(error);
  }
};
