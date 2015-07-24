(function(ns){

	ns.PendingFiles = function(){
		var _summary = { count: 0 };
		var index = 0;
		var _files = [];

		var _getPendingFiles = function(){
			$.ajax({
				type: "POST",
				url: "/domain/pending/files",
				data: { from: index },
				success: function(data){
					data.forEach(function(newFile){
						_files.push(newFile);
					});
					index = index + data.length;
					_pendingFilesSummaryFetched();
				},
				error: function(){
					alert("Error obteniendo la cuenta de pendientes");
				}
			});
		};

		var _getPendingFilesCount = function(){
			$.ajax({
				type: "GET",
				url: "/domain/pending/count",
				success: function(data){
					_summary = data;
					WD.Bus.send("pending-files-summary-fetched", data);
				},
				error: function(){
					alert("Error obteniendo la cuenta de pendientes");
				}
			});
		};

		var _pendingFilesSummaryFetched = function(){
			React.render(
				React.createElement(Page, { summary: _summary, files: _files }),
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

		var Files = React.createClass({displayName: 'Files',
			handleClick: function(){
				_getPendingFiles();
			},
			render: function(){
				var filesNodes = this.props.files.map(function(file){
					return React.createElement("tr", {},
						React.createElement("td", {}, file.title),
						React.createElement("td", {}, file.path),
						React.createElement("td", {}, file.oldOwner),
						React.createElement("td", {}, file.newOwner)
					);
				});
				var filesTable = React.createElement("table", { className: "table table-striped", id: "files" },
					React.createElement("thead", {},
						React.createElement("tr", {},
							React.createElement("td", {}, "Titulo"),
							React.createElement("td", {}, "Path"),
							React.createElement("td", {}, "Antiguo Propietario"),
							React.createElement("td", {}, "Nuevo Propietario")
						)
					),
					React.createElement("tbody", {}, filesNodes)
				);
				var moreBtn = React.createElement("a", { onClick: this.handleClick }, "Más");
				return React.createElement("div", {}, filesTable, moreBtn);
			}
		});

		var Page = React.createClass({displayName: 'Page', 
			render: function(){
				return (
					React.createElement('div', {className: "page"},
						React.createElement(WD.React.Header, { title: "Ficheros Pendientes" }),
						React.createElement(FilesCount, { count: this.props.summary.count }),
						React.createElement(Files, { files: this.props.files })
					)
				);
			}
		});

		WD.Bus.subscribe("pending-files-summary-fetched", _pendingFilesSummaryFetched);
		WD.Bus.subscribe("pending-files-change-all-process-started", function(){
			alert("procesando cambio de permisos para todos los fichero pendientes");
		});

		React.render(
			React.createElement(Page, { summary: _summary, files: _files }),
			document.getElementById('pending-files-page')
		);

		_getPendingFilesCount();
		_getPendingFiles();
	};

	return ns;

}( WD || {} ));