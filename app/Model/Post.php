<?php
App::uses('AppModel', 'Model');
/**
 * Post Model
 * 
 * ブログ記事用モデルです
 * @copyright php_ci_book
 * @link https://github.com/phpcibook/blogapp/blob/master/app/Model/Post.php
 * @since 1.0
 * @auther 山田太郎 <taro@example.com>
 *
 */
class Post extends AppModel {

/**
 * 一覧表示時のタイトルに使用するカラム名
 * 
 * @var string 
 */
	public $displayField = 'title';

/**
 * バリデーションルール
 *
 * @var array
 */
	public $validate = [
		'title' => [
			'notEmpty' => [
				'rule' => ['notEmpty'],
				'message' => 'タイトルは必須入力です',
				//'message' => 'Your custom message here',
				//'allowEmpty' => false,
				//'required' => false,
				//'last' => false, // Stop validation after this rule
				//'on' => 'create', // Limit validation to 'create' or 'update' operations
			],
			'maxLength' => [
				'rule' => ['maxLength', '255'],
				'message' => 'タイトルは255文字以内で入力してください',
			],
		],
	];
}
