declare module "scoped-http-client" {
  export type HttpHeaderName = "Accept" | "Authorization" | "Content-Type";

  export type HttpHeaders = {[n in HttpHeaderName]?: string};

  export type HttpClientResponseHandler = (err: any, res: any, body: any) => void;

  interface HttpClient {
    header(name: HttpHeaderName, value: string): HttpClient;
    headers(hs: HttpHeaders): HttpClient;
    query(ps: {[key: string]: string | number}): HttpClient;
    get(): (callback: HttpClientResponseHandler) => void;
  }

  export function create(url: string): HttpClient;
}