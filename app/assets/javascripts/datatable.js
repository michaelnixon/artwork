$(document).ready(function () {
	$('.panel-collapse').on('show.bs.collapse', function(){
		$(this).parent().find("i").toggleClass('glyphicon-collapse-down glyphicon-collapse-up');
	});  
	$('.panel-collapse').on('hide.bs.collapse', function(){
		$(this).parent().find("i").toggleClass('glyphicon-collapse-down glyphicon-collapse-up');
	});
	$('#mytracks').dataTable({
    "processing": true,
    "serverSide": true,
		"bDeferRender": true,
		"bSortClasses": false,
    "ajax": $('#mytracks').data('source'),
    "pagingType": "full_numbers",
    "columnDefs": [{
        "bSortable": false,
        "aTargets": ['nosort']
    		}]

	  // Optional, if you want full pagination controls.
	  // Check dataTables documentation to learn more about available options.
	  // http://datatables.net/reference/option/pagingType
	});
});