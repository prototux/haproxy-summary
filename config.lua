-- Datacenters
local config = {
	paris = {
		name = "Paris DC",
		url = "http://paris.example.com/haproxy_stats;csv",
		groups = {
			www = {name = "WWW servers", group = "www"},
			static = {name = "Static data servers", group = "static"}
		}
	},
	tokyo = {
		name = "Tokyo DC",
		url = "http://tokyo.example.com/haproxy_stats;csv",
		groups = {
			static = {name = "Static data servers", group = "static"}
		}
	}
}
return config
