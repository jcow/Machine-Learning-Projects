<?php 

require_once('DTBuilder.php');

class DT{

	private $tree = null;

	private $data = array();
	private $classes = array();
	private $potential_values = array();
	private $column_names = array();

	public function __construct(){}

	public function classify($row){
		$node = $this->tree;
		while($node instanceof DTNode){
			$value = $row[$node->column_index];
			$node = $node->children[$value];
		}
		return $node->decision;
	}

	public function build(){
		$this->tree = DTBuilder::build(
			$this->data, 
			$this->classes, 
			$this->potential_values, 
			$this->column_names
		);
	}

	public function setData($data){
		$this->data = $data;
		return $this;
	}

	public function setClasses($classes){
		$this->classes = $classes;
		return $this;
	}

	public function setPotentialValues($potential_values){
		$this->potential_values = $potential_values;
		return $this;
	}

	public function setColumnNames($column_names){
		$this->column_names = $column_names;
		return $this;
	}
}