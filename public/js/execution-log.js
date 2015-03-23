(function(ns){

	ns.ExecutionLog = function(){
		var _records = [];
		var _totalRecordsAtTime = 0;
		var _debugMode = false;

		var _getFromBackend = function(){
			console.log("more records from: " + _records.length + " debug mode: " + _debugMode);
			$.ajax({
				type: "GET",
				url: "/admin/exec-log-records?from=" + _records.length + "&debug=" + _debugMode + "&totalRecordsAtTime=" + _totalRecordsAtTime + "&refresh=" + this.refresh,
				success: function(data){
					WD.Bus.send("exec-log-records-fetched", data);
				},
				error: function(){
					console.log("error getting changed files");
				}
			});
		};

		var Header = React.createClass({displayName: 'Header',
			render: function(){
				return (
					React.createElement('div', { className: "page-header" }, this.props.title)
				);
			}
		});

		var Table = React.createClass({ displayName: 'Table',
			render: function(){
				var createItem = function(item){
					return React.createElement('tr', { className: "file-record file-record-" + item.level },
						React.createElement('td', null, item.domain),
						React.createElement('td', null, item.user),
						React.createElement('td', null, item.message),
						React.createElement('td', null, item.when)
					)
				};
				return (
					React.createElement('table', { className: "table table-striped", id: "log-records-table" },
						React.createElement('thead', {},
							React.createElement('tr', {},
								React.createElement('th', {}, "Dominio"),
								React.createElement('th', {}, "Usuario"),
								React.createElement('th', {}, "Mensaje"),
								React.createElement('th', {}, "Cuando")
							)
						),
						React.createElement('tbody', null, this.props.records.map(createItem))
					)
				);
			}
		});

		var Page = React.createClass({displayName: 'Page', 
			handleDebugMode: function(e){
				WD.Bus.send("debug-mode-status-changed", e.target.checked);
			},
			render: function(){
				return (
					React.createElement('div', {className: "page"},
						React.createElement(Header, { title: "Log de Ejecución" }),
						React.createElement(Table, { records: this.props.records }),
						React.createElement('input', { type: "checkbox", onClick: this.handleDebugMode }, "Debug Mode"),
						React.createElement(ButtonsBox, null)
					)
				);
			}
		});

		var ButtonsBox = React.createClass({displayName: 'ButtonsBox',
			handleMore: _getFromBackend,
			handleRefresh: _getFromBackend.bind({ refresh: true }),
			render: function() {
				return (
					React.createElement('div', {className: "buttonsBox"},
						React.createElement('a', { className: "btn btn-primary", id: "more-btn", onClick: this.handleMore}, "Más"),
						React.createElement('a', { className: "btn btn-primary", onClick: this.handleRefresh}, "Refrescar")
					)
				);
			}
		});

		var _recordsFetched = function(data){
			if (data.from_scratch){
				$("html, body").animate({ scrollTop: 0 }, "slow");
				_totalRecordsAtTime = data.total_at_time;
				_records = data.records;
			}else{
				_records = _records.concat(data.records);
			}
			React.render(
				React.createElement(Page, { records: _records }),
				document.getElementById('exec-log')
			);
		};

		var _debugModeChanged = function(active){
			_debugMode = active;
		};

		WD.Bus.subscribe("exec-log-records-fetched", _recordsFetched);
		WD.Bus.subscribe("debug-mode-status-changed", _debugModeChanged)
		_getFromBackend();

		return {

		}
	};

	return ns;

}( WD || {} ));