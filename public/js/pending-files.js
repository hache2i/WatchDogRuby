(function(ns){

	ns.PendingFiles = function(){
		var _summary = { count: 0 };
		var index = 0;
		var _files = [];

		var _pendingFilesFetched = function(data){
			data.forEach(function(newFile){
				_files.push(newFile);
			});
			index = index + data.length;
			renderEverything();
		};

		var _pendingFilesSummaryFetched = function(data){
			_summary = data;
			renderEverything();
		};

		var renderEverything = function(){
			React.render(
				React.createElement(Page, { summary: _summary, files: _files }),
				document.getElementById('pending-files-page')
			);
		};

		var FilesCount = React.createClass({displayName: "Count",
			handleChangePermissions: function(){
				WD.Backend.changeAllPendingPermissions();
			},
			render: function(){
				return React.createElement('div', { className: "files-count-container" },
					React.createElement('span', null, "Total:"),
					React.createElement('span', null, this.props.count),
					React.createElement('a', { onClick: this.handleChangePermissions }, "Change permissions")
				)
			}
		});

		var ChangeLink = React.createClass({displayName: 'ChangeLink',
			handleClick: function(){
				WD.Backend.changePermission(this.props.permissionId);
			},
			render: function(){
				return React.createElement("a", { onClick: this.handleClick }, "Cambiar");
			}
		});

		var Files = React.createClass({displayName: 'Files',
			handleClick: function(){
				WD.Backend.getPendingFiles(index);
			},
			render: function(){
				var changePermissionFn = this.changePermission;
				var filesNodes = this.props.files.map(function(file){
					return React.createElement("tr", {},
						React.createElement("td", {}, file.title),
						React.createElement("td", {}, file.path),
						React.createElement("td", {}, file.oldOwner),
						React.createElement("td", {}, file.newOwner),
						React.createElement("td", {}, 
							React.createElement(ChangeLink, { permissionId: file._id })
						)
					);
				});
				var filesTable = React.createElement("table", { className: "table table-striped", id: "files" },
					React.createElement("thead", {},
						React.createElement("tr", {},
							React.createElement("td", {}, "Titulo"),
							React.createElement("td", {}, "Path"),
							React.createElement("td", {}, "Antiguo Propietario"),
							React.createElement("td", {}, "Nuevo Propietario"),
							React.createElement("td", {}, "")
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

		WD.Bus.subscribe("pending-files-fetched", _pendingFilesFetched);
		WD.Bus.subscribe("pending-files-summary-fetched", _pendingFilesSummaryFetched);
		WD.Bus.subscribe("pending-files-change-all-process-started", function(){
			alert("procesando cambio de permisos para todos los fichero pendientes");
		});

		renderEverything();
		WD.Backend.getPendingFilesCount();
		WD.Backend.getPendingFiles(index);
	};

	return ns;

}( WD || {} ));