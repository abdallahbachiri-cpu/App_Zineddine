<?php

namespace App\Service\Media;

use App\Entity\Media;
use Doctrine\ORM\EntityManagerInterface;
use Symfony\Component\Filesystem\Filesystem;
use Symfony\Component\HttpFoundation\File\UploadedFile;

class MediaService
{
    // private string $uploadDir;
    private string $publicDir;
    private string $secureDir;
    private Filesystem $filesystem;
    private EntityManagerInterface $entityManager;

    public function __construct(string $uploadDir, EntityManagerInterface $entityManager)
    {
        // $this->uploadDir = $uploadDir;
        $this->publicDir = $uploadDir . '/public';
        $this->secureDir = $uploadDir . '/secure';
        $this->filesystem = new Filesystem();
        $this->entityManager = $entityManager;
    }

    public function upload(UploadedFile $file, string $type = 'image'): Media
    {
        // Validate file type (allow only safe image types)
        // $allowedMimeTypes = ['image/jpeg', 'image/png', 'image/gif', 'image/webp'];
        // if (!in_array($file->getMimeType(), $allowedMimeTypes, true)) {
        //     throw new \InvalidArgumentException('Invalid file type.');
        // }

        // Validate the uploaded file
        if (!$file->isValid()) {
            throw new \RuntimeException('File upload failed: ' . $file->getErrorMessage());
        }

        // @Todo use structured upload directory
        $dateFolder = date('Y') . DIRECTORY_SEPARATOR . date('m');
        // $targetDir = $this->uploadDir . DIRECTORY_SEPARATOR . $type . DIRECTORY_SEPARATOR . $dateFolder;

        // Ensure upload directory exists and is writable
        if (!is_dir($this->publicDir) && !mkdir($this->publicDir, 0755, true) && !is_dir($this->publicDir)) {
            throw new \RuntimeException('Failed to create upload directory.');
        }
        if (!is_writable($this->publicDir)) {
            throw new \RuntimeException('Upload directory is not writable: ' . $this->publicDir);
        }

        // Generate unique file name with original extension
        $extension = $file->getClientOriginalExtension() ?: $file->guessExtension();
        $mimeType = $file->getMimeType();
        $fileSize = $file->getSize();
        $fileOriginalName = $file->getClientOriginalName();

        $fileName = date('Y') . "-" . date('m') . "-" . $fileOriginalName . "-" . uniqid('', true) . '.' . $extension;
        $storagePath = $this->publicDir . DIRECTORY_SEPARATOR . $fileName; // Absolute path
        // $publicUrl = rtrim($this->publicPath, '/') . '/' . $fileName;
        // Move the file
        try {
            $file->move($this->publicDir, $fileName);
        } catch (\Exception $e) {
            throw new \RuntimeException('Failed to move uploaded file: ' . $e->getMessage());
        }

        // Get real storage path after moving
        $storagePath = realpath($this->publicDir . DIRECTORY_SEPARATOR . $fileName);
        if (!$storagePath) {
            throw new \RuntimeException('File was moved but realpath() failed.');
        }

        // Ensure the file is readable
        if (!is_readable($storagePath)) {
            throw new \RuntimeException("File exists but is not readable: $storagePath");
        }

        // Set secure permissions on the file
        chmod($storagePath, 0644);

        // Save media record
        $media = new Media();
        $media->setOriginalName($fileOriginalName);
        $media->setFileName($fileName);
        $media->setStoragePath($storagePath);
        $media->setUrl('');
        $media->setFileType($type);
        $media->setMimeType($mimeType);
        $media->setSize($fileSize);

        $this->entityManager->persist($media);
        $this->entityManager->flush();

        return $media;
    }

    public function delete(Media $media): void
    {
        if ($this->filesystem->exists($media->getStoragePath())) {
            $this->filesystem->remove($media->getStoragePath());
        }

        $this->entityManager->remove($media);
        $this->entityManager->flush();
    }

    public function getMediaUrl(Media $media): string
    {
        return $media->getUrl(); // Returns public URL
    }

    public function uploadSecure(UploadedFile $file, string $type = 'document'): Media
    {
        if (!$file->isValid()) {
            // dd($file->getErrorMessage());
            throw new \RuntimeException('File upload failed: ' . $file->getErrorMessage());
        }

        if (!$this->filesystem->exists($this->secureDir)) {
            $this->filesystem->mkdir($this->secureDir, 0700);
        }

        // Generate secure filename and paths
        $extension = $file->guessExtension() ?: pathinfo($file->getClientOriginalName(), PATHINFO_EXTENSION);
        $fileName = bin2hex(random_bytes(16)) . '.' . $extension;
        $storagePath = $this->secureDir . '/' . $fileName;
        $mimeType = $file->getMimeType();
        $fileSize = $file->getSize();
        $fileOriginalName = $file->getClientOriginalName();

        $file->move($this->secureDir, $fileName);

        $media = new Media();
        $media->setOriginalName($file->getClientOriginalName())
            ->setFileName($fileName)
            ->setStoragePath($storagePath)
            ->setUrl('') // No public URL for secure files
            ->setFileType($type)
            ->setMimeType($mimeType)
            ->setSize($fileSize)
            ->setIsConfidential(true);

        $this->entityManager->persist($media);
        $this->entityManager->flush();

        return $media;
    }

    // New method to download secure files
    public function downloadSecure(Media $media): string
    {
        if (!$media->isConfidential()) {
            throw new \RuntimeException('File is not marked as confidential');
        }

        // @TODO check permission

        if (!$this->filesystem->exists($media->getStoragePath())) {
            throw new \RuntimeException('File not found');
        }

        return file_get_contents($media->getStoragePath());
    }
}
