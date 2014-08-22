package
{
	import com.greensock.TweenMax;
	import com.greensock.easing.Back;
	import com.greensock.easing.Linear;
	import com.greensock.plugins.ShortRotationPlugin;
	import com.greensock.plugins.TransformMatrixPlugin;
	import com.greensock.plugins.TweenPlugin;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.system.Security;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	
	public class carousel extends MovieClip
	{
		//中心位置
		private var centerPoint:Point;  
		//旋转角度
		private var rotation1:Number;		//用于保存外层星座旋转
		private var rotation2:Number;		//用于中间血型旋转
		private var rotation3:Number;		//用于性别男女旋转
        private var result:Object;          //用于结果输出
        private var autoRunSpeed:Number;    //自动运行
		private var autoInterval:uint		//用于保存interval状态
		private var pan:MovieClip;			//底盘
		private var time1:uint;
		private var time2:uint;
		private var time3:uint;
		private var tween1:TweenMax;
		private var tween2:TweenMax;
		private var tween3:TweenMax;
		
		//构造函数
		public function carousel()
		{
			if(!stage)
				addEventListener(Event.ADDED_TO_STAGE,addedToStageHandler);
			else 
				addedToStageHandler();
//			super(); 
		}
		
		
		protected function addedToStageHandler(e:Event = null):void{
			//移除事件
			if(hasEventListener(Event.ADDED_TO_STAGE))
				removeEventListener(Event.ADDED_TO_STAGE,addedToStageHandler);
			Security.allowDomain('*');
			//加载所需插件
			TweenPlugin.activate([ShortRotationPlugin,TransformMatrixPlugin]);
			
			rotation1 = 0;
			rotation2 = 0;
			rotation3 = 0;
			
			init();
			//js调用初始化
			if (ExternalInterface.available){
				try{
					//判断是第一次游戏 还是抽奖状态
					ExternalInterface.addCallback("replayGame",replayGame);
				}catch(e:Error){
					 
				}
			}
		}
		
		/**
		 * 页面初始化
		 */
		public function init():void{
			stage.focus = stage;
			//初始化
            result = {}; 
			centerPoint = new Point(stage.width/2,stage.height/2);

			//显示禁止按钮
			mcOkdisable.visible = true;
			btnOk.visible = false;
			
//			addEvent();
			//事件绑定
			autoInterval = setInterval(autoRunEffect,1500)
			autoRunEffect();
			mcBg.addEventListener(MouseEvent.MOUSE_OVER,disableAutoEffect);
			mcRotationWarp.addEventListener(MouseEvent.MOUSE_OVER,disableAutoEffect);
		}
		
		
		/**
		 * 绑定事件
		 */
		private function addEvent():void{
			//添加hover效果 
//			mcRotationWarp.addEventListener(MouseEvent.MOUSE_OVER,overWarpEvt);
//			mcRotationWarp.addEventListener(MouseEvent.MOUSE_OUT,outWarpEvt);
			//外层
			for(var i = 0;i<12;i++){
				var warp:MovieClip = mcRotationWarp['btnConstellation' + i];
				warp.buttonMode = true;
				warp.addEventListener(MouseEvent.CLICK,rotationWarpEvt);
			}
			//中间层
			for(var j = 0;j<5;j++){
				mcRotationMid['btnConstellation' + j].buttonMode = true;
				mcRotationMid['btnConstellation' + j].addEventListener(MouseEvent.CLICK,rotationMidEvt);
			}
			//里层
			for(var k = 0;k<2;k++){
				mcRotationInner['btnConstellation' + k].buttonMode = true;
				mcRotationInner['btnConstellation' + k].addEventListener(MouseEvent.CLICK,rotationInnerEvt);
			}
			//点击确认按钮
			btnOk.addEventListener(MouseEvent.CLICK,showResultsEvt);
		}
		
		/** 
		 * 鼠标移动上去的效果
		 */
		private function overWarpEvt(e:MouseEvent):void {
//			trace(mcRotationWarp.numChildren,'mcRotationWarp numChildren');
			var target:Object = e.target;
			for(var i = 0;i<12;i++){
				var btnItem:MovieClip = mcRotationWarp['btnConstellation' + i];
				if(target != btnItem || ( result.constellation && btnItem == mcRotationWarp[result.constellation])){
					btnItem.gotoAndStop(2);
				}else{
					btnItem.gotoAndStop(1);
					trace(btnItem.name)
				}
			}
		}
		
		private function outWarpEvt(e:MouseEvent):void {
			var target:Object = e.currentTarget;
			//如果选中了星座
			if(result.constellation){
				for(var i = 0;i<12;i++){
					//非选中的 全部取消
					if(mcRotationWarp[result.constellation] != mcRotationWarp['btnConstellation' + i]){
						mcRotationWarp['btnConstellation' + i].gotoAndStop(2);
					}else{
						//选中的高亮
						mcRotationWarp[result.constellation].gotoAndStop(1);
					}
				}
//				mcRotationWarp[result.constellation].gotoAndStop(1);
			}
		}

        /**
         * 移除事件
         */
        private function removeEvent():void{
            //外层
            for(var i = 0;i<12;i++){
                mcRotationWarp['btnConstellation' + i].removeEventListener(MouseEvent.CLICK,rotationWarpEvt);
            }
            //中间层
            for(var j = 0;j<5;j++){
                mcRotationMid['btnConstellation' + j].removeEventListener(MouseEvent.CLICK,rotationMidEvt);
            }
            //里层
            for(var k = 0;k<2;k++){
                mcRotationInner['btnConstellation' + k].removeEventListener(MouseEvent.CLICK,rotationInnerEvt);
            }
			//点击确认按钮 显示结果
			btnOk.removeEventListener(MouseEvent.CLICK,showResultsEvt);
//
//            //显示结果
//            btnResultsMask.removeEventListener(MouseEvent.CLICK,showResultsEvt);
        }
		

		
		/**
		 * 外层旋转事件
		 */
		private function rotationWarpEvt(e:MouseEvent){
			var targetMc:Object = e.currentTarget;
			//获取角度值
			var angle:Number = getRotation(targetMc,centerPoint);
			//获取需要旋转的角度
			rotation1 += getTweenRotation(angle);
            //保存选中记录
            result.constellation = targetMc.name;
            //执行动画
            TweenMax.to(mcRotationWarp, 1, {shortRotation:{rotation:rotation1},ease:Back.easeOut,onComplete:function(){
				//隐藏其他图层
				for(var i = 0;i<12;i++){
					//非选中的 全部取消
					if(targetMc != mcRotationWarp['btnConstellation' + i]){
						mcRotationWarp['btnConstellation' + i].gotoAndStop(2);
					}else{
						//选中的高亮
						targetMc.gotoAndStop(1);
					}
				}
				//最后再次判断是否在指针处  防止转动时位置计算不准bug
				//获取角度值
				var angle:Number = getRotation(targetMc,centerPoint);
				//获取需要旋转的角度
				rotation1 += getTweenRotation(angle);
				TweenMax.to(mcRotationWarp, 0.2, {shortRotation:{rotation:rotation1},ease:Linear.easeNone});
			}});
			
			checkResults();
		}
		
		private function rotationMidEvt(e:MouseEvent){
			var targetMc:Object = e.currentTarget;
			//获取角度值
			var angle:Number = getRotation(targetMc,centerPoint);
			//获取需要旋转的角度
			rotation2 += getTweenRotation(angle);
            //保存选中记录
            result.blood = targetMc.name;
            //执行动画
			TweenMax.to(mcRotationMid, 1, {shortRotation:{rotation:rotation2},ease:Back.easeOut,onComplete:function(){
				//隐藏其他图层
				for(var i = 0;i<5;i++){
					//非选中的 全部取消
					if(targetMc != mcRotationMid['btnConstellation' + i]){
						mcRotationMid['btnConstellation' + i].gotoAndStop(2);
					}else{
						//选中的高亮
						targetMc.gotoAndStop(1);
					}
				}
				
				//最后再次判断是否在指针处  防止转动时位置计算不准bug
				//获取角度值
				var angle:Number = getRotation(targetMc,centerPoint);
				//获取需要旋转的角度
				rotation2 += getTweenRotation(angle);
				TweenMax.to(mcRotationMid, 0.2, {shortRotation:{rotation:rotation2},ease:Linear.easeNone});
				
			}});
			
			checkResults();
		}
		
		private function rotationInnerEvt(e:MouseEvent){
			var targetMc:Object = e.currentTarget;
			//获取角度值
			var angle:Number = getRotation(targetMc,centerPoint);
			//获取需要旋转的角度
			rotation3 += getTweenRotation(angle);
            //保存选中记录
            result.gender = targetMc.name;
            //执行动画
			TweenMax.to(mcRotationInner, 1, {shortRotation:{rotation:rotation3},ease:Back.easeOut,onComplete:function(){
				mcRotationInner.dipan.gotoAndStop(2);
				//隐藏其他图层
				for(var i = 0;i<2;i++){
					//非选中的 全部取消
					if(targetMc != mcRotationInner['btnConstellation' + i]){
						mcRotationInner['btnConstellation' + i].gotoAndStop(2);
					}else{
						//选中的高亮  
						targetMc.gotoAndStop(1);
					}
				}
				//最后再次判断是否在指针处  防止转动时位置计算不准bug
				//获取角度值
				var angle:Number = getRotation(targetMc,centerPoint);
				//获取需要旋转的角度
				rotation3 += getTweenRotation(angle);
				TweenMax.to(mcRotationInner, 0.2, {shortRotation:{rotation:rotation3},ease:Linear.easeNone});
				
			}});
			
			checkResults();
		}
		
		
		/**
		 * 获取角度值
		 * center 为中心点
		 * target 为目标点
		 */
		private function getRotation(mc:*,center:Point):Number{
			//获取旋转后的坐标
			var mcX:Number = mc.x;
			var mcY:Number = mc.y;
			var target:Point = mc.localToGlobal(new Point(mcX, mcY));
			trace(target);
			//计算角度
			var tmpx:Number=target.x - center.x;  
			var tmpy:Number=center.y - target.y;  
			var angle:Number= Math.atan2(tmpy,tmpx)*(180/Math.PI);  
			return angle;
		}
		
		/**
		 * 获取需要旋转的实际角度
		 * 与getRotation的区别是，getRotation只是获取原始角度值
		 * 而getTweenRotation获取的是与TweenMax实际所需的角度
		 */
		private function getTweenRotation(rotation:Number):Number{
			var _rotation:Number;
			_rotation = rotation - 90;// - 360;
			return _rotation; 
			
		}
		
		/**
		 * 判断是否可以点击
		 */
		private function checkResults():void{
			if(result.constellation && result.blood && result.gender){
				mcOkdisable.visible = false;
				btnOk.visible = true;
			}
		}
		

        /**
         * 显示结果
         * @param e
         */
        private function showResultsEvt(e:MouseEvent):void{
            //释放内存
            removeEvent();
			//加载底盘
			pan = new McPan();
			pan.x = 344.5;
			pan.y = 345.45;
			pan.scaleX = 0;
			pan.scaleY = 0;
			pan.alpha = 0;
			addChild(pan);
			
			//搞个动画
			//外层
			for(var i = 0;i<12;i++){
				mcRotationWarp['btnConstellation' + i].gotoAndStop(2);
			}
			//中间层
			for(var j = 0;j<5;j++){
				mcRotationMid['btnConstellation' + j].gotoAndStop(2);
			}
			//里层
			for(var k = 0;k<2;k++){
				mcRotationInner['btnConstellation' + k].gotoAndStop(2);
			}
			rotation1 += 1800;
			rotation2 -= 1800;
			rotation3 += 1800;
			TweenMax.to(mcRotationWarp, 3, {rotation:rotation1});
			TweenMax.to(mcRotationMid, 3, {rotation:rotation2});
			TweenMax.to(mcRotationInner, 3, {rotation:rotation3});
			
			
			if (ExternalInterface.available){
				try{ 
					ExternalInterface.call("Pui.carousel.gameCompleteBefore",result);
				}catch(e:Error){
					
				}
			}
			
			TweenMax.to(pan, 0.5, {delay:3, scaleX:1, scaleY:1, alpha:1,rotation:-360,onComplete:function(){
				if (ExternalInterface.available){
					try{ 
						//通知页面已经完成 并输出结果
						ExternalInterface.call("Pui.carousel.gameComplete",result);
					}catch(e:Error){
						
					}
				}
			},onStart:function(){
				if (ExternalInterface.available){
					try{ 
						//通知页面已经完成 并输出结果
						ExternalInterface.call("Pui.carousel.gameStart",result);
					}catch(e:Error){
						
					}
				}
			}});


            trace(result);
        }

        /**
         * 默认动画
         */
		private function autoRunEffect():void {
			
			var autoRunSpeed1 = Math.random() * 100;
			var autoRunSpeed2 = -Math.random() * 100;
			var autoRunSpeed3 = Math.random() * 100;
			tween1 = TweenMax.to(mcRotationWarp, 10, {rotation:autoRunSpeed1,ease:Linear.easeNone});
			tween2 = TweenMax.to(mcRotationMid, 12, {rotation:autoRunSpeed2,ease:Linear.easeNone});
			tween3 = TweenMax.to(mcRotationInner, 15, {rotation:autoRunSpeed3,ease:Linear.easeNone});
        }

        /**
         * 停止自动旋转效果
         */
        private function disableAutoEffect(e:Event):void {
//            removeEventListener(Event.ENTER_FRAME, autoRunEffect);
			clearInterval(autoInterval);
			tween1.kill();
			tween2.kill(); 
			tween3.kill();
			mcBg.removeEventListener(MouseEvent.MOUSE_OVER,disableAutoEffect); 
			mcRotationWarp.removeEventListener(MouseEvent.MOUSE_OVER,disableAutoEffect);
            addEvent();
        }
		
		/**
		 * 重新开始游戏
		 */
		public function replayGame():void{ 
			mcRotationInner.dipan.gotoAndStop(1);
			//外层
			for(var i = 0;i<12;i++){
				mcRotationWarp['btnConstellation' + i].gotoAndStop(1);
			}
			//中间层
			for(var j = 0;j<5;j++){
				mcRotationMid['btnConstellation' + j].gotoAndStop(1);
			}
			//里层
			for(var k = 0;k<2;k++){
				mcRotationInner['btnConstellation' + k].gotoAndStop(1);
			}
			//存在的话 则移除
			if(pan){
				TweenMax.to(pan, 0.5, {scaleX:0, scaleY:0, alpha:0,rotation:360,onComplete:function(){
					removeChild(pan);
					pan = null;
				}});
			}
			init();
		}

	}
}