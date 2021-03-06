<?php

require_once('Utils.php');
require_once('libs/Combinatorics.php');

class CE{

	public $data;
	public $classes;
	public $positive_val;
	public $negative_val;

	public $s;
	public $g;
	public $interior;

	public function __construct($data, $classes, $pos, $neg){
		$this->data = $data;
		$this->classes = $classes;

		$data_keys = array_keys($data);
		$this->s = array_fill(0, count($data[$data_keys[0]]), null);
		
		$this->g = array();

		$this->positive_val = $pos;
		$this->negative_val = $neg;
	}

	public function isPositiveExample($val){
		return $val === $this->positive_val;
	}

	public function isSMaxSpecific($s){
		$is = true;
		foreach($s as $val){
			if($val !== null){
				$is = false;
				break;
			}
		}
		return $is;
	}

	public function fillG($s, $index, $value){
		$array = array_fill(0, count($s), '?');
		$array[$index] = $value;
		return $array;
	}

	public function makeNewS($row, $s, $g){
		for($i = 0; $i < count($s); $i++){
			if($row[$i] !== $s[$i]){
				$s[$i] = '?';
			}
		}
		return $s;
	}

	public function makeNewG($row, $s, $g){
		for($i = 0; $i < count($s); $i++){
			if($s[$i] !== '?' && $s[$i] !== $row[$i]){
				$g[$i] = $this->fillG($s, $i, $s[$i]);
			}
		}
		return $g;
	}

	public function pruneG($row, $s, $g){
		for($i = 0; $i < count($s); $i++){
			if($s[$i] !== '?' && $s[$i] !== $row[$i]){
				unset($g[$i]);	
			}
		}

		return $g;
	}

	public function classify($row){
		$arr = array_merge(array($this->s), $this->g, $this->interior);

		$matches = 0;
		foreach($arr as $values){
			$match = $this->match($values, $row);
			if($match){
				$matches++;
			}
		}
		$nonmatches = count($arr)-$matches;

		if($matches === $nonmatches){
			return 'undefined';
		}
		else if($matches > $nonmatches){
			return $this->positive_val;
		}
		else{
			return $this->negative_val;
		}
	}

	public function match($values, $row){
		$matched = true;
		
		for($i = 0; $i < count($values); $i++){
			$vval = $values[$i];
			$rval = $row[$i];
			
			if($vval !== '?' && $rval !== $vval){
				$matched = false;
				break;
			}
		}
		return $matched;
	}

	public function interiorExpressions($s, $g){

		$s_count = $this->questionCount($s);
		$g_keys = array_keys($g);
		$g_count = $this->questionCount($g[$g_keys[0]]);
		
		$non_q_count = 0;
		$vals = array();
		for($i = 0; $i < count($s); $i++){
			if($s[$i] !== '?'){
				$vals[] = $i;
			}
			$non_q_count++;
		}

		$choose_counts = array();
		for($i = $s_count+1; $i < $g_count; $i++){
			$choose_counts[] = $non_q_count-$i;
		}

		$interior = array();
		foreach($choose_counts as $num){
			$combinatorics = new Math_Combinatorics();
			$combinations = $combinatorics->combinations($vals, $num);

			$dummy = array_fill(0, count($s), '?');
			foreach($combinations as $combination){
				$new = $dummy;
				foreach($combination as $index){
					$new[$index] = $s[$index];
				}
				$interior[] = $new;
			}
		}
		
		return $interior;
	}

	public function questionCount($arr){
		$count = 0;
		foreach($arr as $val){
			if($val === '?'){
				$count++;
			}
		}
		return $count;
	}

	public function run(){

		$counter = 0;
		foreach($this->data as $index=>$row){
			$class = $this->classes[$index];

			if($this->isPositiveExample($class)){
					if($this->isSMaxSpecific($this->s)){
						$this->s = $row;
					}
					else{
						$this->g = $this->pruneG($row, $this->s, $this->g);
						$this->s = $this->makeNewS($row, $this->s, $this->g);
					}	
			}
			else{
				$this->g = $this->makeNewG($row, $this->s, $this->g);
			}

			$counter++;
		}

		$this->interior = $this->interiorExpressions($this->s, $this->g);

	}

}