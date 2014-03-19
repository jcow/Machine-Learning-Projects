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