import API from './httpClient';

/**
 * Permanently deletes the authenticated user's account and all associated
 * data. Required by Apple App Store guidelines (GDPR / App Review 5.1.1).
 */
export async function deleteAccount(): Promise<void> {
  await API.delete('/user/account');
}
