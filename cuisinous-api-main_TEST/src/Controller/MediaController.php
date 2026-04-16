<?php

namespace App\Controller;

use App\Entity\Media;
use App\Entity\User;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\BinaryFileResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\HttpFoundation\ResponseHeaderBag;
use Symfony\Component\Routing\Annotation\Route;

#[Route('/api/media', name: 'media_')]
class MediaController extends AbstractController
{
    #[Route('/{id}', name: 'show', methods: ['GET'])]
    public function show(Media $media, Request $request): Response
    {

        if ($media->isConfidential()) {
            //TODO: handle confidential media
            $user = $this->getUser();
            if (!$user instanceof User || $user->getType() !== User::TYPE_ADMIN) {
                return new Response('Unauthorized', Response::HTTP_UNAUTHORIZED);
            }
        }

        $path = $media->getStoragePath();

        if (!is_file($path) || !is_readable($path)) {
            return new Response('File not found', Response::HTTP_NOT_FOUND);
        }

        // 2. Stream file (NO memory load)
        $response = new BinaryFileResponse($path);
        $response->setPublic(!$media->isConfidential());

        // 3. Content headers
        $response->headers->set('Content-Type', $media->getMimeType());
        $response->headers->set(
            'Content-Disposition',
            $response->headers->makeDisposition(
                ResponseHeaderBag::DISPOSITION_INLINE,
                $media->getOriginalName()
            )
        );

        // 4. Enable range requests (video/audio/PDF preview)
        $response->headers->set('Accept-Ranges', 'bytes');

        // 5. Cache strategy
        if (!$media->isConfidential()) {
            $response->setMaxAge(31536000);      // 1 year
            $response->setSharedMaxAge(31536000);
            $response->setImmutable(true);

            // Strong caching
            $response->setEtag(md5($media->getFileName() . $media->getSize()));
            $response->setLastModified(
                (new \DateTime())->setTimestamp(filemtime($path))
            );

            // Return 304 if not modified
            if ($response->isNotModified($request)) {
                return $response;
            }
        } else {
            // Secure files: no cache
            $response->headers->set('Cache-Control', 'no-store, private');
        }

        return $response;
    }
}
