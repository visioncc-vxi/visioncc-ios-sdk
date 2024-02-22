//
//  EvaluateViewController.swift
//  Tool
//
//  Created by apple on 2024/1/4.
//

import UIKit
import SnapKit

/// 满意度评价(新窗口中打开)
class EvaluateViewController: UIViewController {
    
    private var viewModel:VXIChatViewModel?
    
    //MARK: override
    init(viewModel: VXIChatViewModel? = nil) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.view.backgroundColor = VXIUIConfig.shareInstance.appViewControlelrBackgroundColor()
        
        self.view.addSubview(self.navView)
        self.view.addSubview(self.mainView)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        VXIUIConfig.shareInstance.appSetNavigationeStyleFor(Hidden: true, andViewController: self)
    }
    
    override func updateViewConstraints() {
        
        if self.view.subviews.contains(self.mainView){
            self.mainView.snp.makeConstraints { make in
                make.left.right.equalTo(0)
                make.top.equalTo(VXIUIConfig.shareInstance.xp_navigationFullHeight())
                make.bottom.equalTo(-VXIUIConfig.shareInstance.xp_safeDistanceBottom())
            }
        }
        
        if self.view.subviews.contains(self.navView){
            self.navView.snp.makeConstraints { make in
                make.left.top.right.equalToSuperview()
                make.height.equalTo(VXIUIConfig.shareInstance.xp_navigationFullHeight())
            }
        }
        
        super.updateViewConstraints()
    }
    
    //MARK: - lazy laod
    private lazy var navView:UIView = {
        return TGSUIModel.createDiyNavgationalViewFor(TitleStr: "",
                                                      andDisposeBag: rx.disposeBag) {[weak self] in
            guard let self = self else { return }
            self.navigationController?.popViewController(animated: true)
        }
    }()
    
    private lazy var mainView:EvaluateBoxView = {[unowned self] in
        let _v = EvaluateBoxView.init(isNewViewController: true,
                                      andViewModel: self.viewModel ?? VXIChatViewModel.init())
        return _v
    }()
    
}
