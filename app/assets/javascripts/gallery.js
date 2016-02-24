var Gallery = {
	init: function(){
		$('.datepicker1').datepicker({ format: 'dd-mm-yyyy' }).on('changeDate', function (ev) {
			    $("#yearly_comparison").val("");
		});
  	$('.datepicker2').datepicker({ format : 'dd-mm' }).on('changeDate', function (ev) {
		    $("input.time-range").val("");
		});
    	$("#map-big-view").attr("href", $("#map-big-view").parent().parent().find("iframe").attr("src") );
		this.project_change_init();
		this.date_compare_change_init();
	},
	date_compare_change_init: function(){
		$("#yearly_comparison").change(function(){
			$("input.time-range").val("");
		});
	},
	project_change_init: function(){
		$("#project-select-field").change(function(){
			var url = $(this).data("get-site");
			var project_id = $(this).find("option:selected").val();
			$("#site-select-field").attr("disabled", true);
			$.ajax({
				url: url,
				data: {project_id: project_id},
				success: function(data){
					if (data.status == "200") {
						var option_list = "";
						for (item in data.sites) {
							option_list += "<option value='"+ data.sites[item].slug +"'>" + data.sites[item].Name + "</option>";
						}
						$("#site-select-field").removeAttr("disabled");
						$("#site-select-field").html(option_list);
					}
				}
			});
		});
	}
}