const { IndividualActionPlan, IapTask } = require('../models');

class IapController {
  /**
   * @route POST /api/v1/iaps
   */
  createIap = async (req, res, next) => {
    try {
      const { enterprise_id, status, tasks } = req.body;
      const coach_id = req.user.userId;

      // Use a transaction for bulk creation
      const { sequelize } = require('../models');
      const result = await sequelize.transaction(async (t) => {
        const iap = await IndividualActionPlan.create({
          enterprise_id,
          coach_id,
          status: status || 'active'
        }, { transaction: t });

        if (tasks && tasks.length > 0) {
          const tasksWithIapId = tasks.map(task => ({
            ...task,
            iap_id: iap.id
          }));
          await IapTask.bulkCreate(tasksWithIapId, { transaction: t });
        }

        return await IndividualActionPlan.findByPk(iap.id, {
          include: [{ model: IapTask, as: 'tasks' }],
          transaction: t
        });
      });

      res.status(201).json({ success: true, data: result });
    } catch (error) {
      next(error);
    }
  };

  /**
   * @route GET /api/v1/iaps/enterprise/:enterpriseId
   */
  getIapsByEnterprise = async (req, res, next) => {
    try {
      const iaps = await IndividualActionPlan.findAll({
        where: { enterprise_id: req.params.enterpriseId },
        include: [{ model: IapTask, as: 'tasks' }]
      });
      res.status(200).json({ success: true, count: iaps.length, data: iaps });
    } catch (error) {
      next(error);
    }
  };

  /**
   * @route POST /api/v1/iaps/:iapId/tasks
   */
  addTask = async (req, res, next) => {
    try {
      const { description, deadline, status, evidence_url } = req.body;
      const iap_id = req.params.iapId;

      const task = await IapTask.create({ iap_id, description, deadline, status, evidence_url });
      
      res.status(201).json({ success: true, data: task });
    } catch (error) {
      next(error);
    }
  };

  /**
   * @route PUT /api/v1/iaps/tasks/:taskId
   */
  updateTask = async (req, res, next) => {
    try {
      const task = await IapTask.findByPk(req.params.taskId);
      if (!task) return res.status(404).json({ success: false, message: 'Task not found' });
      
      await task.update(req.body);
      
      res.status(200).json({ success: true, data: task });
    } catch (error) {
      next(error);
    }
  };

  /**
   * @route POST /api/v1/iaps/tasks/:taskId/evidence
   * Accepts a single file upload and stores its URL on the task.
   */
  uploadEvidence = async (req, res, next) => {
    try {
      if (!req.file) {
        return res.status(400).json({ success: false, message: 'No file provided' });
      }

      const task = await IapTask.findByPk(req.params.taskId);
      if (!task) return res.status(404).json({ success: false, message: 'Task not found' });

      // Build a publicly accessible URL for the uploaded file
      const baseUrl = `${req.protocol}://${req.get('host')}`;
      const fileUrl = `${baseUrl}/uploads/evidence/${req.file.filename}`;

      await task.update({ evidence_url: fileUrl });

      res.status(200).json({
        success: true,
        message: 'Evidence uploaded successfully',
        data: { evidence_url: fileUrl, task }
      });
    } catch (error) {
      next(error);
    }
  };
  /**
   * @route POST /api/v1/iaps/tasks/:taskId/evidence
   * Accepts a single file upload and stores its URL on the task.
   */
  uploadEvidence = async (req, res, next) => {
    try {
      if (!req.file) {
        return res.status(400).json({ success: false, message: 'No file provided' });
      }

      const task = await IapTask.findByPk(req.params.taskId);
      if (!task) return res.status(404).json({ success: false, message: 'Task not found' });

      const baseUrl = `${req.protocol}://${req.get('host')}`;
      const fileUrl = `${baseUrl}/uploads/evidence/${req.file.filename}`;

      await task.update({ evidence_url: fileUrl });

      res.status(200).json({
        success: true,
        message: 'Evidence uploaded successfully',
        data: { evidence_url: fileUrl, task }
      });
    } catch (error) {
      next(error);
    }
  };

  /**
   * @route GET /api/v1/iaps/:iapId/progress
   * Returns completion stats: total tasks, completed, pending, overdue, percentage.
   */
  getIapProgress = async (req, res, next) => {
    try {
      const iap = await IndividualActionPlan.findByPk(req.params.iapId, {
        include: [{ model: IapTask, as: 'tasks' }]
      });
      if (!iap) return res.status(404).json({ success: false, message: 'IAP not found' });

      const now = new Date();
      const total = iap.tasks.length;
      const completed = iap.tasks.filter(t => t.status === 'completed').length;
      const overdue = iap.tasks.filter(
        t => t.status === 'pending' && new Date(t.deadline) < now
      ).length;
      const pending = total - completed;
      const percentage = total === 0 ? 0 : Math.round((completed / total) * 100);

      res.status(200).json({
        success: true,
        data: { iap_id: iap.id, total, completed, pending, overdue, percentage }
      });
    } catch (error) {
      next(error);
    }
  };
}

module.exports = new IapController();
