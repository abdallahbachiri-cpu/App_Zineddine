// src/services/mercureService.ts
// Wraps native EventSource with exponential-backoff reconnection and
// multi-topic subscription management. Modelled after the pattern used
// in Uber Eats / DoorDash dashboards.

export type MercureMessageCallback = (data: Record<string, unknown>) => void;

interface TopicState {
  callbacks: MercureMessageCallback[];
  eventSource: EventSource | null;
  reconnectAttempts: number;
  reconnectTimer: ReturnType<typeof setTimeout> | null;
}

const BASE_RECONNECT_DELAY_MS = 3_000;
const MAX_RECONNECT_DELAY_MS  = 30_000;

class MercureService {
  private topics   = new Map<string, TopicState>();
  private hubUrl   = '';
  private token: string | null = null;
  private onConnectionChange: ((connected: boolean) => void) | null = null;

  /** Called once after fetching the token from /api/mercure/token */
  configure(hubUrl: string, token: string | null): void {
    this.hubUrl = hubUrl;
    this.token  = token;
  }

  /** Register a callback for a topic. Returns an unsubscribe function. */
  subscribe(topic: string, callback: MercureMessageCallback): () => void {
    if (!this.topics.has(topic)) {
      this.topics.set(topic, {
        callbacks: [],
        eventSource: null,
        reconnectAttempts: 0,
        reconnectTimer: null,
      });
      this.openConnection(topic);
    }

    const state = this.topics.get(topic)!;
    state.callbacks.push(callback);

    return () => this.removeCallback(topic, callback);
  }

  /** Attach a listener that fires whenever ANY topic's connection state changes */
  setConnectionChangeHandler(handler: (connected: boolean) => void): void {
    this.onConnectionChange = handler;
  }

  isConnected(topic: string): boolean {
    const state = this.topics.get(topic);
    return state?.eventSource?.readyState === EventSource.OPEN;
  }

  disconnectAll(): void {
    this.topics.forEach((_, topic) => this.closeTopic(topic));
  }

  private openConnection(topic: string): void {
    const state = this.topics.get(topic);
    if (!state || !this.hubUrl) return;

    try {
      const url = new URL(this.hubUrl);
      url.searchParams.append('topic', topic);
      if (this.token) {
        url.searchParams.append('authorization', this.token);
      }

      const es = new EventSource(url.toString());
      state.eventSource = es;

      es.onopen = () => {
        state.reconnectAttempts = 0;
        this.onConnectionChange?.(true);
      };

      es.onmessage = (event: MessageEvent) => {
        try {
          const data = JSON.parse(event.data) as Record<string, unknown>;
          state.callbacks.forEach(cb => cb(data));
        } catch {
          // Ignore malformed payloads
        }
      };

      es.onerror = () => {
        es.close();
        state.eventSource = null;
        this.onConnectionChange?.(false);
        this.scheduleReconnect(topic);
      };
    } catch {
      this.scheduleReconnect(topic);
    }
  }

  private scheduleReconnect(topic: string): void {
    const state = this.topics.get(topic);
    if (!state || state.reconnectTimer !== null) return;

    const delay = Math.min(
      BASE_RECONNECT_DELAY_MS * Math.pow(1.5, state.reconnectAttempts),
      MAX_RECONNECT_DELAY_MS
    );
    state.reconnectAttempts += 1;

    state.reconnectTimer = setTimeout(() => {
      state.reconnectTimer = null;
      if (this.topics.has(topic)) {
        this.openConnection(topic);
      }
    }, delay);
  }

  private removeCallback(topic: string, callback: MercureMessageCallback): void {
    const state = this.topics.get(topic);
    if (!state) return;

    state.callbacks = state.callbacks.filter(cb => cb !== callback);

    if (state.callbacks.length === 0) {
      this.closeTopic(topic);
    }
  }

  private closeTopic(topic: string): void {
    const state = this.topics.get(topic);
    if (!state) return;

    state.eventSource?.close();

    if (state.reconnectTimer !== null) {
      clearTimeout(state.reconnectTimer);
    }

    this.topics.delete(topic);
  }
}

// Singleton — shared across the whole React app
export const mercureService = new MercureService();
