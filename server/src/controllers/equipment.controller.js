const equipmentService = require('../services/equipment.service');

class EquipmentController {
  addEquipment = async (req, res, next) => {
    try {
      const asset = await equipmentService.addEquipment(req.body);
      res.status(201).json({ success: true, data: asset });
    } catch (error) { next(error); }
  };

  getEnterpriseAssets = async (req, res, next) => {
    try {
      const assets = await equipmentService.getEnterpriseAssets(req.params.enterpriseId);
      res.status(200).json({ success: true, data: assets });
    } catch (error) { next(error); }
  };

  updateStatus = async (req, res, next) => {
    try {
      const asset = await equipmentService.updateEquipmentStatus(req.params.id, req.body.status, req.body.notes);
      res.status(200).json({ success: true, data: asset });
    } catch (error) { next(error); }
  };

  getAllAssets = async (req, res, next) => {
    try {
      const assets = await equipmentService.getAllEquipment();
      res.status(200).json({ success: true, data: assets });
    } catch (error) { next(error); }
  };
}

module.exports = new EquipmentController();
