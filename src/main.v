module main

import net
import net.http

fn main() {
	listener := net.listen_tcp(net.AddrFamily.ip, '127.0.0.1') or {
		panic('create listener error | err: ${err}')
	}
	mut server := http.Server{
		listener: listener
		port: 8888
		handler: ExampleHandler{}
	}

	// start server
	server.listen_and_serve()
}

struct ExampleHandler {}

fn (h ExampleHandler) handle(req http.Request) http.Response {

	// fetch response from `pkmn.li`
	mut res := http.fetch(http.FetchConfig{
		url: 'https://pkmn.li'
		method: http.Method.get
		user_agent: 'curl/8.0.1'
	}) or {
			// 500 http response if fetch error
		http.Response{
			body: 'fetch error | err: ${err}'
			header: http.new_header_from_map({
				http.CommonHeader.content_type: 'text/plain'
			})
			status_code: 500
		}
	}

	// since vlang http only support for chunked reader but not chunked writer
	// so we manually reset content-length == res.body.length instead of fetch response transfer-encoding: chunked
	res.header.delete(http.CommonHeader.transfer_encoding)
	res.header.set(http.CommonHeader.content_length, res.body.len.str())
	return res
}
