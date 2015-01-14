$('button').text('Add Folder');

	$('tbody tr').on('mouseenter', function() {
		$(this).addClass('selected-blue');
	});
	$('tr').on('mouseleave', function() {
		$(this).removeClass('selected-blue');
	});

$('tbody tr').on('click', function() {
	if($(this).children().children().is(':checked')){
		$(this).removeClass('selected-red');
		$(this).children().children().prop('checked',false);
	}
	else{
		$(this).addClass('selected-red');
		$(this).children().children().prop('checked',true);
		}
	});

$('button').on('click', function() {
	$('table').prepend('<tr><td><input type="checkbox"></td><td><img src=\"imgs/e-fld.png\" /></td><td>Filename</td><td>10KB</td></tr>');
	$('tbody tr').on('mouseenter', function() {
		$(this).addClass('selected-blue');
	});
	$('tr').on('mouseleave', function() {
		$(this).removeClass('selected-blue');
	});

$('tbody tr').on('click', function() {
	if($(this).children().children().is(':checked')){
		$(this).removeClass('selected-red');
		$(this).children().children().prop('checked',false);
	}
	else{
		$(this).addClass('selected-red');
		$(this).children().children().prop('checked',true);
		}
	});
});