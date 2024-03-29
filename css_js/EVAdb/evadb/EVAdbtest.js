
$(document).ready(function() {
   $('form:first *:input[type=text]:first').focus();
   $("input:text, input:password").focus(function () { });//attach the focus event find the autofocus field
   $('input[autofocus]').trigger('focus');//force fire it on the autofocus element

});

// ##########################################################################################################


// jquery
// function checkboxes to select function in search form	
$().ready(function () {
	$('button#nonsynonymous').click({
				function      : ['unknown','missense','nonsense','stoploss','splice','frameshift','indel']
	}, handleClickFunction);
	$('button#lof').click({
				function      : ['nonsense','stoploss','splice','frameshift']
	}, handleClickFunction);
	$('button#synonymous').click({
				function      : ['unknown','syn','nearsplice','5utr','3utr','noncoding','mirna','intronic','intergenic','regulation']
	}, handleClickFunction); 
	$('button#none').click({
				function      : []
	}, handleClickFunction); 
	$('button#all').click({
				function      : ['unknown','syn','missense','nonsense','stoploss','splice','nearsplice','frameshift','indel','5utr','3utr','noncoding','mirna','intronic','intergenic','regulation']
	}, handleClickFunction); 
});


function handleClickFunction(event) {
	$('input[name="function"]').val(event.data.function);
}

// ##########################################################################################################
	
// jquery
// default values for structural variation search in genome database
$().ready(function () {
	$('button#cnvnator').click({svlenmin  : '5000',
				svlenmax        : '',
				annotation      : [''],
				gapoverlap      : '',
				giaboverlap     : '0.4',
				lowcomploverlap : '0.2',
				dgvoverlap      : '10',
				ncaller         : '',
				caller          : ['cnvnator']
	}, handleClickSv); 
	$('button#pindel').click({svlenmin    : '',
				svlenmax        : '5000',
				annotation      : [''],
				gapoverlap      : '',
				giaboverlap     : '0.4',
				lowcomploverlap : '0.2',
				dgvoverlap      : '10',
				ncaller         : '2',
				caller          : ['pindel','lumpy-sv']
	}, handleClickSv); 
});


function handleClickSv(event) {
	$('input[name="svlenmin"]').val(event.data.svlenmin);
	$('input[name="svlenmax"]').val(event.data.svlenmax);
	$('input[name="annotation"]').val(event.data.annotation);
	$('input[name="gapoverlap"]').val(event.data.gapoverlap);
	$('input[name="giaboverlap"]').val(event.data.giaboverlap);
	$('input[name="lowcomploverlap"]').val(event.data.lowcomploverlap);
	$('input[name="dgvoverlap"]').val(event.data.dgvoverlap);
	$('input[name="ncaller"]').val(event.data.ncaller);
	$('input[name="caller"]').val(event.data.caller);
}

// ##########################################################################################################
// contextmenu for resultsexomestatistics

function contextM(counter,idsample,sname,pedigree){
	var counter;
	var idsample;
	var sname;
	var pedigree;
	$(function(){
		$.contextMenu({
			selector: '.context-menu-one'+counter, 
				items: {
			            "ad":           {name: "<a href='search.pl?pedigree="+pedigree+"'>Autosomal dominant</a>",
				    			callback: function(key,opt){
								var pedigree = opt.$trigger.attr("idsample");
								//alert(idsample);
								return pedigree;
							}
				    		    },
			            "ar":           {name: "<a href='searchGeneInd.pl?pedigree="+sname+"'>Autosomal recessive</a>"},
			            "denovo":       {name: "<a href='searchTrio.pl?pedigree="+sname+"'>De novo trio</a>"},
			            "tumor":        {name: "<a href='searchTumor.pl?pedigree="+sname+"'>Tumor/Control</a>"},
			            "diseasegene":  {name: "<a href='searchDiseaseGene.pl?sname="+sname+"'>Diseasegenes</a>"},
			            "hgmd":         {name: "<a href='searchHGMD.pl?sname="+sname+"'>HGMD/ClinVar</a>"},
			            "omim":         {name: "<a href='searchOmim.pl?sname="+sname+"'>OMIM</a>"},
			            "diagnostics":  {name: "<a href='searchDiagnostics.pl?sname="+sname+"'>Coverage lists</a>"},
			            "homozygosity": {name: "<a href='searchHomo.pl?sname="+sname+"'>Homozygosity</a>"},
			            "cnv":          {name: "<a href='searchCnv.pl?sname="+sname+"'>CNV</a>"},
			            "HPO":          {name: "<a href='searchHPO.pl?sname="+sname+"'>HPO</a>"},
			            "sample":       {name: "<a href='searchSample.pl?pedigree="+pedigree+"'>Sample information</a>"},
			            "conclusion":   {name: "<a href='conclusion.pl?idsample="+idsample+"'>Sample conclusions</a>"},
			            "report":       {name: "<a href='report.pl?sname="+sname+"'>Report</a>"},
				}
		});
	});
};
// ##########################################################################################################
// contextmenu for resultsexomestatistics genome with structural variants

function contextMg(counter,idsample,sname,pedigree){
	var counter;
	var idsample;
	var sname;
	var pedigree;
	$(function(){
		$.contextMenu({
			selector: '.context-menu-one'+counter, 
				items: {
			            "ad":           {name: "<a href='search.pl?pedigree="+pedigree+"'>Autosomal dominant</a>",
				    			callback: function(key,opt){
								var pedigree = opt.$trigger.attr("idsample");
								//alert(idsample);
								return pedigree;
							}
				    		    },
			            "ar":           {name: "<a href='searchGeneInd.pl?pedigree="+sname+"'>Autosomal recessive</a>"},
			            "denovo":       {name: "<a href='searchTrio.pl?pedigree="+sname+"'>De novo trio</a>"},
			            "tumor":        {name: "<a href='searchTumor.pl?pedigree="+sname+"'>Tumor/Control</a>"},
			            "diseasegene":  {name: "<a href='searchDiseaseGene.pl?sname="+sname+"'>Diseasegenes</a>"},
			            "hgmd":         {name: "<a href='searchHGMD.pl?sname="+sname+"'>HGMD/ClinVar</a>"},
			            "omim":         {name: "<a href='searchOmim.pl?sname="+sname+"'>OMIM</a>"},
			            "diagnostics":  {name: "<a href='searchDiagnostics.pl?sname="+sname+"'>Coverage lists</a>"},
			            "homozygosity": {name: "<a href='searchHomo.pl?sname="+sname+"'>Homozygosity</a>"},
			            "cnv":          {name: "<a href='searchCnv.pl?sname="+sname+"'>CNV</a>"},
			            "sv":           {name: "<a href='searchSv.pl?sname="+sname+"'>Structural variants</a>"},
			            "HPO":          {name: "<a href='searchHPO.pl?sname="+sname+"'>HPO</a>"},
			            "sample":       {name: "<a href='searchSample.pl?pedigree="+pedigree+"'>Sample information</a>"},
			            "conclusion":   {name: "<a href='conclusion.pl?idsample="+idsample+"'>Sample conclusions</a>"},
			            "report":       {name: "<a href='report.pl?sname="+sname+"'>Report</a>"},
				}
		});
	});
};
// ##########################################################################################################
// contextmenu for ad, denovo and tumor

function contextComment(counter,idsnv,idsample,reason){
	var counter;
	var idsnv;
	var idsample;
	var reason;
	$(function(){
		$.contextMenu({
			selector: '.context-menu-one'+counter,
			items: {
				"comment":    {name: "<a href='comment.pl?idsnv="+idsnv+"&idsample="+idsample+"&reason="+reason+"' title='Comment page'>Comment</a>"},
			}
		});
	});
};

// ##########################################################################################################
// contextmenu for recessive plus parents

function contextCommentParents(counter,idsnv,idsample,reason,mother,father){
	var counter;
	var idsnv;
	var idsample;
	var reason;
	var mother;
	var father;
	$(function(){
		$.contextMenu({
			selector: '.context-menu-one'+counter,
			items: {
				"comment":    {name: "<a href='comment.pl?idsnv="+idsnv+"&idsample="+idsample+"&reason="+reason+"' title='Comment page'>Comment</a>"},
			}
		});
	});
};

// ##########################################################################################################
// dataTables default


$(document).ready( function () {
         var oTable = $('#default').DataTable({
 	"dom":           "Bfrtip",
 	"paginate":      true,
  	"lengthChange":  true,
	"filter":        true,
 	"sort":          true,
	"info":          true,
	"autoWidth":     false,
	"orderClasses":  false,
	"displayLength": 10000,
	"lengthMenu": [[-1, 10000, 1000, 500, 100], ["All", 10000, 1000, 500, 100]],
	"select":         'multi',
 	"buttons":        [	{
					extend: 'pageLength',
					fade: 0
				},
				{
	    				extend: 'csv',
					exportOptions: {
						format: {
							body: function ( data, row, column, node ) {
								// Strip $ from salary column to make it numeric
								if (column === 1) {
									//replace all html
									data = data.replace(/(&nbsp;|<([^>]+)>)/ig, "");
									data = data.replace(/\t|\n/g, "");
									// replace everything except first word
									data = data.replace(/^(\s*\w+)\s+.*$/, "$1");
								}
								else {
									data = data.replace(/(&nbsp;|<([^>]+)>)/ig, "");
								}
								return data;
								}
						}
					}
					
				}
			],
	"fixedHeader":    true,
	"aoColumnDefs": [
		{ "sType": "num",
		  //"aTargets": [$('#default').attr('numeric')]
		  "aTargets": []
		},
		{ "sType": "string",
		  //"aTargets": [$('#default').attr('string')]
		  "aTargets": []
		},
		{ "sType": "html",
		  //"aTargets": [$('#default').attr('html')]
		  "aTargets": []
		}
	]
});


    oTable.on( 'order.dt search.dt', function () {
        oTable.column(0, {search:'applied', order:'applied'}).nodes().each( function (cell, i) {
            cell.innerHTML = i+1;
        } );
    } ).draw();
	//test
	//document.write($('#default').attr('string'))

});

// ##########################################################################################################
// dataTables results


$(document).ready( function () {
 var Table = $('#results').DataTable({
 	"dom":           "Bfrtip",
	"stateSave":     true,
	"stateDuration": 604800,
	"paginate":      true,
  	"lengthChange":  true,
	"filter":        true,
 	"sort":          true,
	"info":          true,
	"autoWidth":     false,
	"orderClasses":  false,
	"displayLength": 10000,
	"lengthMenu": [[-1, 10000, 1000, 500, 100], ["All", 10000, 1000, 500, 100]],
	"select":         'multi',
 	"buttons":        [	{
					extend: 'pageLength',
					fade: 0
				},
				{
					extend: 'colvis',
					postfixButtons: ['colvisRestore'],
					text: 'Toggle columns',
					fade: 0,
					collectionLayout: 'fixed three-column'
				},
				{
					extend: 'colvisGroup',
					text: 'Show all columns',
					show: ':hidden'
				},
			'csv'],
	"fixedHeader":    true,
	"columnDefs":	[
			{
				"targets": [3,4,5,7,8,11,12,13,24,25,26,27,28,29,30,31,32,33,34,35,37],
				"visible": false
			},
			{
				"targets": [36],
				"width": 600
			}
			]
});

    $('a.toggle-vis').on('click', function (e) {
        e.preventDefault();
 
        // Get the column API object
	var str = $(this).attr('data_column');
	var res = str.split(",");
	res.forEach(aaaa)
	function aaaa(item, index) {
        	var column = Table.column( item );
         	column.visible( ! column.visible() );
	}
    } );	
		
    Table.on( 'order.dt search.dt', function () {
        Table.column(0, {search:'applied', order:'applied'}).nodes().each( function (cell, i) {
            cell.innerHTML = i+1;
        } );
    } ).draw();
	//test
	//document.write($('#default').attr('string'))

});


// ##########################################################################################################
// dataTables resultsTestButtons


$(document).ready( function () {
 var oTable = $('#resultsTest').DataTable({
 	"dom":           "Bfrtip",
	"stateSave":     true,
 	"paginate":      true,
  	"lengthChange":  true,
	"filter":        true,
 	"sort":          true,
	"info":          true,
	"autoWidth":     false,
	"orderClasses":  false,
	"displayLength": 10000,
	"lengthMenu": [[-1, 10000, 1000, 500, 100], ["All", 10000, 1000, 500, 100]],
	"select":         'multi',
 	"buttons":        ['pageLength','csv',
				{
					extend: 'colvis',
					postfixButtons: ['colvisRestore']
				},
				{
					extend: 'colvisGroup',
					text: 'Show all',
					show: ':hidden'
				},
				{
					extend: 'colvisGroup',
					text: 'Predictions',
					hide: [25,26,27,28]
				},
				{
					extend: 'colvisGroup',
					text: 'Quality',
					hide: [30,31,32,33,34,35]
				}
			],
	"fixedHeader":    true,
	"aoColumnDefs": [
		{ "sType": "num",
		  //"aTargets": [$('#default').attr('numeric')]
		  "aTargets": []
		},
		{ "sType": "string",
		  //"aTargets": [$('#default').attr('string')]
		  "aTargets": []
		},
		{ "sType": "html",
		  //"aTargets": [$('#default').attr('html')]
		  "aTargets": []
		}
	]
});
	
    oTable.on( 'order.dt search.dt', function () {
        oTable.column(0, {search:'applied', order:'applied'}).nodes().each( function (cell, i) {
            cell.innerHTML = i+1;
        } );
    } ).draw();
	//test
	//document.write($('#default').attr('string'))

});
// ##########################################################################################################
// dataTables default new


$(document).ready( function () {
 var secondTable = $('#table02').DataTable({
 	"dom":           "Bfrtip",
 	"paginate":      true,
  	"lengthChange":  true,
	"filter":        true,
 	"sort":          true,
	"info":          true,
	"autoWidth":     false,
	"orderClasses":  false,
	"displayLength": 10000,
	"lengthMenu": [[-1, 10000, 1000, 500, 100], ["All", 10000, 1000, 500, 100]],
	"select":         'multi',
 	"buttons":        ['pageLength','csv'],
	"fixedHeader":    true,
	"aoColumnDefs": [
		{ "sType": "num",
		  //"aTargets": [$('#default').attr('numeric')]
		  "aTargets": []
		},
		{ "sType": "string",
		  //"aTargets": [$('#default').attr('string')]
		  "aTargets": []
		},
		{ "sType": "html",
		  //"aTargets": [$('#default').attr('html')]
		  "aTargets": []
		}
	]
});


    secondTable.on( 'order.dt search.dt', function () {
        secondTable.column(0, {search:'applied', order:'applied'}).nodes().each( function (cell, i) {
            cell.innerHTML = i+1;
        } );
    } ).draw();
	//test
	//document.write($('#table02').attr('string'))

});


// ##########################################################################################################
// dataTables default new


$(document).ready( function () {
 var thirdTable = $('#table03').DataTable({
 	"dom":           "Bfrtip",
 	"paginate":      true,
  	"lengthChange":  true,
	"filter":        true,
 	"sort":          true,
	"info":          true,
	"autoWidth":     false,
	"orderClasses":  false,
	"displayLength": 10000,
	"lengthMenu": [[-1, 10000, 1000, 500, 100], ["All", 10000, 1000, 500, 100]],
	"select":         'multi',
 	"buttons":        ['pageLength','csv'],
	"fixedHeader":    true,
	"aoColumnDefs": [
		{ "sType": "num",
		  //"aTargets": [$('#default').attr('numeric')]
		  "aTargets": []
		},
		{ "sType": "string",
		  //"aTargets": [$('#default').attr('string')]
		  "aTargets": []
		},
		{ "sType": "html",
		  //"aTargets": [$('#default').attr('html')]
		  "aTargets": []
		}
	]
});


    thirdTable.on( 'order.dt search.dt', function () {
        thirdTable.column(0, {search:'applied', order:'applied'}).nodes().each( function (cell, i) {
            cell.innerHTML = i+1;
        } );
    } ).draw();
	//test
	//document.write($('#table03').attr('string'))

});

// ##########################################################################################################



/* When the user clicks on the button, 
toggle between hiding and showing the dropdown content */
function myFunction(n) {
  var n;
  n = "myDropdown"+n;
    // Close the dropdown if the user clicks on another dropdown icon
    var dropdowns = document.getElementsByClassName("dropdown-content");
    var dropdownClicked = document.getElementById(n);
    var i;
    for (i = 0; i < dropdowns.length; i++) {
      var openDropdown = dropdowns[i];
      if (openDropdown != dropdownClicked) {
      if (openDropdown.classList.contains('show')) {
        openDropdown.classList.remove('show');
      }
      }
    }
  document.getElementById(n).classList.toggle("show");
}

// Close the dropdown if the user clicks outside of it
window.onclick = function(event) {
  if (!event.target.matches('.dropbtn')) {
    var dropdowns = document.getElementsByClassName("dropdown-content");
    var i;
    for (i = 0; i < dropdowns.length; i++) {
      var openDropdown = dropdowns[i];
      if (openDropdown.classList.contains('show')) {
        openDropdown.classList.remove('show');
      }
    }
  }
}


// ##########################################################################################################
// Sidebar menu

/* Set the width of the side navigation to 250px and the left margin of the page content to 250px */
function openNav() {
  document.getElementById("mySidenav").style.width = "220px";
  document.getElementById("main").style.marginLeft = "220px";
}

/* Set the width of the side navigation to 0 and the left margin of the page content to 0 */
function closeNav() {
  document.getElementById("mySidenav").style.width = "0";
  document.getElementById("main").style.marginLeft = "0";
} 

