<?php


class Confusion{

	private $matrix = array();
	private $accuracy = 0;

	function __construct($potential_values){
		$this->_makeBaseValues($potential_values);
	}

	function add($guess, $actual){
		$this->matrix[$guess][$actual]++;
	}

	function setAccuracy($accuracy){
		$this->accuracy = $accuracy;
	}

	function getAccuracy(){
		return $this->accuracy;
	}

	function getMatrix(){
		return $this->matrix;
	}

	private function _makeBaseValues($potential_values){
		foreach($potential_values as $i){
			$this->matrix[$i] = array();
			foreach($potential_values as $p){
				$this->matrix[$i][$p] = 0;
			}
		}
	}
}