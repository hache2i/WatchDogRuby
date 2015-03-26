(function(ns){

	ns.PendingFiles = function(){
		var _summary = {};

		var _getPendingFilesCount = function(){
			$.ajax({
				type: "GET",
				url: "/domain/pending/count",
				success: function(data){
					WD.Bus.send("pending-files-summary-fetched", data);
				},
				error: function(){
					alert("Error obteniendo la cuenta de pendientes");
				}
			});
		};

		var _pendingFilesSummaryFetched = function(data){
			console.log(data);
			_summary = data;
			React.render(
				React.createElement(Page, { summary: _summary }),
				document.getElementById('pending-files-page')
			);
		};

		var FilesCount = React.createClass({displayName: "Count",
			handleChangePermissions: function(){
				$.ajax({
					type: "POST",
					url: "/domain/pending/change/all",
					success: function(data){
						WD.Bus.send("pending-files-change-all-process-started");
					},
					error: function(){
						alert("Error cambiando los permisos para todos los ficheros pendientes")
					}
				});
			},
			render: function(){
				return React.createElement('div', { className: "files-count-container" },
					React.createElement('span', null, "Total:"),
					React.createElement('span', null, this.props.count),
					React.createElement('a', { onClick: this.handleChangePermissions }, "Change permissions")
				)
			}
		});

		var Page = React.createClass({displayName: 'Page', 
			render: function(){
				return (
					React.createElement('div', {className: "page"},
						React.createElement(WD.React.Header, { title: "Ficheros Pendientes" }),
						React.createElement(FilesCount, { count: this.props.summary.count })
					)
				);
			}
		});

		WD.Bus.subscribe("pending-files-summary-fetched", _pendingFilesSummaryFetched);
		WD.Bus.subscribe("pending-files-change-all-process-started", function(){
			alert("procesando cambio de permisos para todos los fichero pendientes");
		});

		_getPendingFilesCount();
	};

	return ns;

}( WD || {} ));