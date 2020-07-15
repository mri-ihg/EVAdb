
var hits;
var phenotypeslist=document.getElementById("phenotype_choices");
var details=[];
var copied=[];
var last_index=-1;

function SubmitAutocompletionPhenotype() {
	var term=document.hpoform.query.value;   // Input term   
	//var phenotypeslist=document.getElementById("phenotype_choices");
	if (term.length<4) {
		return;
	}
	var req;  // The variable that makes Ajax possible!	
	details=[];
	copied=[];

	try {	   
		// Opera 8.0+, Firefox, Safari
		req = new XMLHttpRequest();
	} catch (e) {
	 
		try {
			// Internet Explorer Browsers
			req = new ActiveXObject("Msxml2.XMLHTTP");
		} catch (e) {
	    
			try {
				req = new ActiveXObject("Microsoft.XMLHTTP");
			} catch (e) {
				// Something went wrong
				alert("Your browser broke!");
				return false;
			}
		}
	}
      
	// Create a function that will receive data
	// sent from the server and will update
	// div section in the same page.
	req.onreadystatechange = function() {
		if((req.readyState == 4) && (req.status == 200)) {
			hits = JSON.parse(req.responseText);
			for (var i = 0; i < hits.length; i++) {
				var obj=hits[i];
				details[i]='<a onClick="AddPL(event,'+i+')"> '+obj[0] +'</a>' + ' ' + obj[1];
			}
			PhenotypeList();
		}
	};
      
	// Now get the values from server
	req.open("POST", "hpo.pl", true);
	req.setRequestHeader('Content-Type','application/x-www-form-urlencoded');
	req.send('term=' + term); 
}

function PhenotypeList () {
	phenotypeslist.innerHTML='<a href="javascript:ClosePL()">close</a><br>'+details.join("<br>\n")+'<br><a href="javascript:ClosePL()">close</a>';
	if (phenotypeslist.style.display == 'none') phenotypeslist.style.display='' ;
	phenotypeslist.style.height="30em";
}

function ClosePL() {
	phenotypeslist.style.display = 'none';
}

function AddPL(e,i){
	if (last_index<0){
		last_index=i;
	}
	else {
		if (e.shiftKey) {
			MultipleSelectPL([i, last_index]);
		}
		last_index=-1;
	}
	CopyTermPL(i);
	PhenotypeList();
}

function MultipleSelectPL(limits) {
    limits.sort(function(a, b) {
        return a - b;
    });

    for (var i = limits[0]; i <= limits[1]; i++) {
        CopyTermPL(i);
    }
}

function CopyTermPL(i) {
	if (copied[i]) return;
	copied[i]=1;
	var oldtext=document.hpoform.phenotype.value;
	if (oldtext.length) {
		document.hpoform.phenotype.value=oldtext+"\n"+hits[i][0]+' '+hits[i][1];
	}
	else {
		document.hpoform.phenotype.value=hits[i][0]+' '+hits[i][1];
	}
	details[i]='<SPAN style="background-color:grey">'+details[i]+'</SPAN>';
}

// for HPO list
var toggler = document.getElementsByClassName("caret");
var i;

for (i = 0; i < toggler.length; i++) {
  toggler[i].addEventListener("click", function() {
    this.parentElement.querySelector(".nested").classList.toggle("active");
    this.classList.toggle("caret-down");
  });
}
function CopyTermFromList(termFromList) {
	var oldtext=document.hpoform.phenotype.value;
	if (oldtext.length) {
		document.hpoform.phenotype.value=oldtext+"\n"+termFromList;
	}
	else {
		document.hpoform.phenotype.value=termFromList;
	}
}
