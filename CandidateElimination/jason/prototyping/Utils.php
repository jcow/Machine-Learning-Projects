<?php

function col($array, $index){
	$ret = array();
	foreach($array as $key=>$row){
		$ret[$key] = $row[$index];
	}
	return $ret;
}

function rm_col($array, $index){
	foreach($array as $k=>$v){
		if(array_key_exists($index, $array[$k])){
			unset($array[$k][$index]);
		}
	}
	return $array;
}

function read_csv($filename, $sep = ','){
	$ret = array();
	if (($handle = fopen($filename, "r")) !== FALSE) {
	    while (($data = fgetcsv($handle, 1000, $sep)) !== FALSE) {
	        $num = count($data);
	        $temp = array();
	        for ($c=0; $c < $num; $c++) {
	            $temp[] = $data[$c];
	        }
	        $ret[] = $temp;
	    }
	    fclose($handle);
	}
	return $ret;
}

function p($matrix, $accuracy){
	print("--------------------------------------------------------------------------\n");
	printf("|%-15.15s |%-15.15s  %-15.15s  %-15.15s |\n", '    Guesses', '', '     Actual', '');

	$mask = "|%-15.15s |%-15.15s |%-15.15s |%-15.15s |\n";
	printf($mask, '', 'Enjoy Sport', 'Do Not Enjoy', 'Undefined');

	foreach($matrix as $k1=>$v){
		printf($mask, ucfirst($k1), $v['Enjoy Sport'], $v['Do Not Enjoy'], $v['undefined']);		
	}

	printf("Percent Accurate: $accuracy\n");
}