const fs = require('fs');
const path = require('path');

/**
 * StorageService provides an abstraction over local disk and cloud storage (S3/R2).
 * Requirement N: "Migrate local evidence storage to Cloud". 
 * This service implements the local version with a switch for S3.
 */
class StorageService {
  constructor() {
    this.uploadPath = path.join(__dirname, '../uploads');
    if (!fs.existsSync(this.uploadPath)) {
      fs.mkdirSync(this.uploadPath, { recursive: true });
    }
    
    this.useCloud = process.env.STORAGE_TYPE === 's3';
  }

  async saveFile(fileBuffer, fileName, folder = '') {
    if (this.useCloud) {
       // Mock S3 implementation
       console.log(`[STORAGE SERVICE] Uploading ${fileName} to S3 bucket...`);
       return `https://s3.mesmer.app/${folder}/${fileName}`;
    } else {
      const fullDir = path.join(this.uploadPath, folder);
      if (!fs.existsSync(fullDir)) fs.mkdirSync(fullDir, { recursive: true });
      
      const fullPath = path.join(fullDir, fileName);
      fs.writeFileSync(fullPath, fileBuffer);
      return `/uploads/${folder}/${fileName}`;
    }
  }

  async deleteFile(fileUrl) {
    if (this.useCloud) {
      console.log(`[STORAGE SERVICE] Deleting ${fileUrl} from S3...`);
    } else if (fileUrl.startsWith('/uploads/')) {
      const relativePath = fileUrl.replace('/uploads/', '');
      const fullPath = path.join(this.uploadPath, relativePath);
      if (fs.existsSync(fullPath)) fs.unlinkSync(fullPath);
    }
  }
}

module.exports = new StorageService();
