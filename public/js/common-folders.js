(function(ns){

	ns.CommonFolders = function(){

		var _folders = [];

		var Table = React.createClass({ displayName: 'Table',
			render: function(){
				var createItem = function(item){
					return React.createElement('tr', { className: "file-record file-record-" + item.level },
						React.createElement('td', null, item.title)
					)
				};
				return (
					React.createElement('table', { className: "table table-striped" },
						React.createElement('thead', {},
							React.createElement('tr', {},
								React.createElement('th', {}, "Nombre")
							)
						),
						React.createElement('tbody', null, this.props.folders.map(createItem))
					)
				);
			}
		});

		var _commonsFoldersFetched = function(data){
			console.log(data.folders);
			_folders = data.folders;

			React.render(
				React.createElement(Table, { folders: _folders }),
				document.getElementById('common-folders-container')
			);
		};

		WD.Bus.subscribe("common-folders-fetched", _commonsFoldersFetched);

		$.ajax({
			type: "GET",
			url: "/domain/common-folders",
			success: function(data){
				WD.Bus.send("common-folders-fetched", data);
			},
			error: function(){
				alert("Error obteniendo carpetas comunes");
			}
		});

	};

	return ns;

}( WD || {} ));