// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require twitter/bootstrap
//= require_tree .

$list_instances = function(zone, next_token) {
	$.ajax({
		type: 'GET',
		url: '/aws_actions/load_instances',
		data: {next_token: next_token, zone: zone},
		dataType: 'html',
		success: function(data){
			$('div#list-instances').html(data);
		},
		error: function(e){
			$('div#list-instances').html("<div class='well'><center>Some error occured while loading instances. Please verify your AWS creds.</center></div>");
		},
		beforeSend: function(){
			$('div#list-instances').html("<div><center><img src='/assets/loading.gif' style='align:center'/></center></div>");
		}
	});
};

$list_snapshots = function() {
	$.ajax({
		type: 'GET',
		url: '/aws_actions/load_snapshots',
		dataType: 'html',
		success: function(data){
			$('div#list-snapshots').html(data);
		},
		error: function(e){
			$('div#list-snapshots').html("<div class='well'><center>Some error occured while loading snapshots. Please verify your AWS creds.</center></div>");
		},
		beforeSend: function(){
			$('div#list-snapshots').html("<div><center><img src='/assets/loading.gif' style='align:center'/></center></div>");
		}
	});
};

$list_volumes = function() {
	$.ajax({
		type: 'GET',
		url: '/aws_actions/load_volumes',
		dataType: 'html',
		success: function(data){
			$('div#list-volumes').html(data);
		},
		error: function(e){
			$('div#list-volumes').html("<div class='well'><center>Some error occured while loading volumes. Please verify your AWS creds.</center></div>");
		},
		beforeSend: function(){
			$('div#list-volumes').html("<div><center><img src='/assets/loading.gif' style='align:center'/></center></div>");
		}
	});
};

$create_instant_snapshot = function(id){
	$.ajax({
		type: 'GET',
		url: '/aws_actions/create_instant_snapshot',
		data: {volume_id: id},
		success: function(){
			$("#created_snapshot").modal('toggle');
		},
		error: function(e){
			alert("error")
		}
	});
};

$delete_snapshot = function($row, id) {
	$.ajax({
		type: 'GET',
		url: '/aws_actions/delete_snapshot',
		data: {snapshot_id: id},
		success: function(){
			$row.html("<td colspan='6'><center><b>Snapshot " + id +" Deleted Successfully!!!</b></center></td>");
			setTimeout(function () {
				$row.fadeOut('slow');
			}, 2000);
		},
		error: function(e){
			$row.html("<td colspan='6'><center><b>Some Error occuring while deleting this snapshot!!</b></center></td>");
		},
		beforeSend: function() {
			$row.html("<td colspan='6'><center><b>Deleting Snapshot " + id +" ..........</b></center></td>");
		}
	});
};

$(document).on('click', '.load-more-instances', function() {
	var zone = $('#select-availability-zone :selected').val();
	var next_token = $(this).attr('id');
	$list_instances(zone, next_token);
});

$(document).on('change', '#select-availability-zone', function() {
	var zone = $('#select-availability-zone :selected').val();
	$list_instances(zone, '');
});

$(document).on('click', '.create_instant_snapshot', function(){
 $create_instant_snapshot($(this).attr('id'));
});

$(document).on('change', '#select-instance-filter', function() {
	var filter = $('#select-instance-filter :selected').val();
	if(filter == "None") {
		$('#filter-key').hide();
		$('#filter-value').hide();
	}
	else if(filter == "Tags") {
		$('#filter-key').show();
		$('#filter-value').show();
	}
	else {
		$('#filter-value').show();
	}
});
