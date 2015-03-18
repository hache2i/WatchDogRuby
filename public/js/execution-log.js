(function(ns){

	ns.ExecutionLog = function(){
		var _records = [];

		var Header = React.createClass({displayName: 'Header',
			render: function(){
				return (
					React.createElement('div', { className: "page-header" }, "Execution Log")
				);
			}
		});

		var Table = React.createClass({ displayName: 'Table',
			render: function(){
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
						React.createElement('tbody')
					)
				);
			}
		});

		var Page = React.createClass({displayName: 'Page', 
			render: function(){
				return (
					React.createElement('div', {className: "page"},
						React.createElement(Header, null),
						React.createElement(Table, null),
						React.createElement(ButtonsBox, null)
					)
				);
			}
		});

		var ButtonsBox = React.createClass({displayName: 'ButtonsBox',
		  render: function() {
		    return (
		      React.createElement('div', {className: "buttonsBox"},
		        React.createElement('a', { className: "btn btn-primary", id: "more-btn"}, "Más")
		      )
		    );
		  }
		});

		React.render(
		  React.createElement(Page, null),
		  document.getElementById('exec-log')
		);

		$("#more-btn").click(function(){
			$.ajax({
				type: "GET",
				url: "/admin/exec-log-records?from=" + _records.length,
				success: _recordsFetched,
				error: function(){
					console.log("error getting changed files");
				}
			});
		});

		var _recordsFetched = function(data){
			_records = _records.concat(data.records);
			var body = $("#log-records-table tbody");
			body.empty();
			_records.forEach(function(item){
				var row = $("<tr class='file-record file-record-" + item.level + "'>");
				var user = $("<td>");
				user.html(item.user);
				row.append(user);
				var domain = $("<td>");
				domain.html(item.domain);
				row.append(domain);
				var message = $("<td>");
				message.html(item.message);
				row.append(message);
				var when = $("<td>");
				when.html(item.when);
				row.append(when);
				body.append(row);
			});
		};

		$.ajax({
			type: "GET",
			url: "/admin/exec-log-records",
			success: _recordsFetched,
			error: function(){
				console.log("error getting changed files");
			}
		});

		return {

		}
	};

	return ns;

}( WD || {} ));