/* globals $:false */

$.fn.inputPlaceholder = function(){
	'use strict';
	return this.each(function(){
		var input = $(this);
		var label = $('label[for='+input.attr('id')+']');
		if (!input.is('[placeholder]')) {
			label.addClass('overlay');
			input.on('focus',function(){
				label.addClass('hidden');
			}).on('blur',function(){
				setTimeout(function(){
					if (input.val() === '') {
						label.removeClass('hidden');
					} else {
						label.addClass('hidden');
					}
				},150);
			});
			if (input.val() !== '') input.triggerHandler('focus');
		}
	});
};