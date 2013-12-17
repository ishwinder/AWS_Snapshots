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

$list_instances = function(zone, next_token, filter, key, value){
	$.ajax({
		type: 'GET',
		url: '/aws_actions/load_instances',
		data: { next_token: next_token, zone: zone, filter: filter, key: key, value: value},
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

$create_instant_snapshot = function($btn, id){
	$.ajax({
		type: 'GET',
		url: '/aws_actions/create_instant_snapshot',
		data: {volume_id: id},
		success: function(){
			$btn.removeAttr('disabled');
			$("#created_snapshot").modal('toggle');
		},
		error: function(e){
			$btn.removeAttr('disabled');
			alert("error");
		},
		beforeSend: function(){
			$btn.attr('disabled', 'disabled');
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

$list_instances_summary = function() {
	$.ajax({
		type: 'GET',
		url: '/dashboard/load_instances_summary',
		dataType: 'html',
		success: function(data){
			$('div#instances_summary').html(data);
		},
		error: function(e){
			$('div#instances_summary').html("<div class='well'><center>Some error occured while loading instances. Please verify your AWS creds.</center></div>");
		},
		beforeSend: function(){
			$('div#instances_summary').html("<div style='margin-bottom: 10px;'><center><img src='/assets/loading.gif' style='align:center'/></center></div>");
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
	$("#filter-value").val("");
	$("#filter-key").val("");
	$list_instances(zone, '', '', '', '');
});

$(document).on('click', '.create_instant_snapshot', function() {
	$create_instant_snapshot($(this).closest('div').children('button'), $(this).attr('id'));
});

$(document).on('click', '.delete_snapshot', function() {
	$delete_snapshot($(this).closest('tr'), $(this).attr('id'));
});

$(document).on('change', '#select-instance-filter', function() {
	var filter = $('#select-instance-filter :selected').val();
	var zone = $('#select-availability-zone :selected').val()
	$("#filter-value").val("");
	$("#filter-key").val("");
	if(filter == "None") {
		$('#filter-key').hide();
		$('#filter-value').hide();
		$('#search-by-filter').hide();
		$list_instances(zone, '', filter,'','');
	}
	else if(filter == "Tags") {
		$('#filter-key').show();
		$('#filter-value').show();
		$('#search-by-filter').show();
	}
	else {
		$('#filter-key').hide();
		$('#filter-value').show();
		$('#search-by-filter').show();
	}
});

$(function() {
	$('.date-picker').datepicker({autoclose: true}).on('changeDate', function(ev){
		if ($(this).attr('name').indexOf('start')> -1){
			summary('#from-start-time', $(this).val());
		}
		else{
			summary('#from-end-time', $(this).val());
		}
	
	});
	$('#timepicker1').timepicker({
		minuteStep: 60,
	}).on('changeTime.timepicker', function(e) {
		summary('#timeat', e.time.value);
	});
	
});
function summary(elem, value){
	$(elem).html(value);
}
$(document).on('change', '#scheduled_snapshot_frequency', function(){
	$selct = $('#scheduled_snapshot_frequency').val();
	$('div[id^="schedule"]').hide();
	$('div#schedule-'+$selct).show();
});

$(document).on('change', "#validation-form #frequency-type, #validation-form input:checkbox", function(){
	$selct = $('#frequency-type').val();
	$('div[id^="schedule"]').hide();
	$('div#schedule-'+$selct).show();
	var values = new Array();
	$('div#schedule-'+$selct+ ' input:checked').each(function() {
	    values.push( $(this).siblings('span').html() );
	});
	$('#repeattype').html($selct);
	$('#repeat-on').html(values);
});

$(document).on('click', '.search_filters', function() {
	var filter = $('#select-instance-filter :selected').val();
	var value = $("#filter-value").val();
	var key = $("#filter-key").val();
	var zone = $('#select-availability-zone :selected').val();

	if(filter == "Tags") {
		$list_instances(zone, '', filter,key,value);
	}
	else{
		$list_instances(zone, '', filter,"",value);
	}
	
});

$(document).ready(function(){
	var filter = $('#select-instance-filter :selected').val();
	if(filter == "None") {
		$('#search-by-filter').hide();
	}
});
