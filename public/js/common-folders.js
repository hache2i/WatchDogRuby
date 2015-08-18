(function(ns){

	ns.CommonFolders = function(){

		var _folders = [];

		var Table = React.createClass({ displayName: 'Table',
			render: function(){
				var createItem = function(item){
					var multipleParentsClass = "";
					if (item.parents > 1){
						multipleParentsClass = "multiple-parents";
					}
					return React.createElement('tr', { className: "file-record " + multipleParentsClass },
						React.createElement('td', null, item.title),
						React.createElement('td', null, React.createElement("a", { onClick: function(){
							WD.Backend.getDetails(item.id);
						} }, "Detalles"))
					)
				};
				return (
					React.createElement('table', { className: "table table-striped" },
						React.createElement('thead', {},
							React.createElement('tr', {},
								React.createElement('th', {}, "Nombre"),
								React.createElement('th', {}, "")
							)
						),
						React.createElement('tbody', null, this.props.folders.map(createItem))
					)
				);
			}
		});

		var _commonsFoldersFetched = function(data){
			_folders = data.folders;

			React.render(
				React.createElement(Table, { folders: _folders }),
				document.getElementById('common-folders-container')
			);
		};

		WD.Bus.subscribe("common-folders-fetched", _commonsFoldersFetched);

		WD.Backend.getCommonFolders();

	};

	return ns;

}( WD || {} ));