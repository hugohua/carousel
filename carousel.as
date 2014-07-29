package
{
	import com.greensock.TweenMax;
	import com.greensock.easing.Back;
	import com.greensock.plugins.ShortRotationPlugin;
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
			TweenPlugin.activate([ShortRotationPlugin]);
			init();
		}
		
		/**
		 * 页面初始化
		 */
		public function init():void{
			//初始化
			rotation1 = 0;
			rotation2 = 0;
			rotation3 = 0;
            result = {};
			centerPoint = new Point(stage.width/2,stage.height/2);

			//事件绑定
//			autoInterval = setInterval(autoRunEffect,2000)
//			autoRunEffect();
            stage.addEventListener(MouseEvent.MOUSE_OVER,disableAutoEffect);
		}
		
		
		/**
		 * 绑定事件
		 */
		private function addEvent():void{
			mcRotationWarp.addEventListener(MouseEvent.CLICK,overWarpEvt);
			mcRotationWarp.addEventListener(MouseEvent.MOUSE_OVER,overWarpEvt);
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

            //显示结果
//            btnResultsMask.addEventListener(MouseEvent.CLICK,showResultsEvt);
		}
		
		private function overWarpEvt(e:MouseEvent):void{
			var target:Object = e.target;
			for(var i = 0;i<12;i++){
				if(target != mcRotationWarp['btnConstellation' + i]){
					mcRotationWarp['btnConstellation' + i].gotoAndStop(2);
				}else{
					target.gotoAndStop(1);
				}
			}
		}
		
		private function outWarpEvt(e:MouseEvent):void{
			var target:Object = e.currentTarget;
			for(var i = 0;i<12;i++){
				if(target != mcRotationWarp['btnConstellation' + i]){
					mcRotationWarp['btnConstellation' + i].gotoAndStop(1);
				}else{
					target.gotoAndStop(1);
				}
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
            TweenMax.to(mcRotationWarp, 1, {shortRotation:{rotation:rotation1},ease:Back.easeOut});
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
			TweenMax.to(mcRotationMid, 1, {shortRotation:{rotation:rotation2},ease:Back.easeOut});
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
			TweenMax.to(mcRotationInner, 1, {shortRotation:{rotation:rotation3},ease:Back.easeOut});
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
			_rotation = rotation - 90 - 360;
			return _rotation;
			
		}
		
		/**
		 * 判断是否可以点击
		 */
//		private function checkResults():void{
//
//			btnResultsMask.visible = !(result.constellation && result.blood && result.gender);
//		}
		

        /**
         * 显示结果
         * @param e
         */
        private function showResultsEvt(e:MouseEvent):void{
            //释放内存
            removeEvent();


            if (ExternalInterface.available){
                try{
                    //通知页面已经完成 并输出结果
                    ExternalInterface.call("gameComplete",result);
                }catch(e:Error){

                }
            }
            trace(result);
        }

        /**
         * 默认动画
         */
		private function autoRunEffect():void {
            var autoRunSpeed = Math.random() * 100;
            TweenMax.to(mcRotationWarp, 20, {shortRotation:{rotation:autoRunSpeed}});
            TweenMax.to(mcRotationMid, 20, {shortRotation:{rotation:autoRunSpeed}});
            TweenMax.to(mcRotationInner, 20, {shortRotation:{rotation:autoRunSpeed}});
        }

        /**
         * 停止自动旋转效果
         */
        private function disableAutoEffect(e:Event):void {
            removeEventListener(Event.ENTER_FRAME, autoRunEffect);
			clearInterval(autoInterval);
			stage.removeEventListener(MouseEvent.MOUSE_OVER,disableAutoEffect);
            addEvent();

        }

	}
}