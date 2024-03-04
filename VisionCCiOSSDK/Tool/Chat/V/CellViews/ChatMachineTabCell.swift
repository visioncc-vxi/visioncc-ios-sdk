//
//  ChatMachineTabCell.swift
//  Tool
//
//  Created by CQP-MacPro on 2023/12/27.
//

import UIKit
import SnapKit
import JXSegmentedView

/// 热点问题列表(分栏菜单)
class ChatMachineTabCell: BaseChatCell {
    
    /// 点击回调
    public var clickCellBlock:((_ _selectedIndex:Int, _ _item:MessageGroupItems)->Void)?
    private let page_size:Int = 4//每页展示条数
    
    
    //MARK: - overrddie
    override func layoutUI() {
        super.layoutUI()
        contentView.addSubview(self.bgView)
        
        let _h:CGFloat = CGFloat(74) + CGFloat(page_size) * VXIUIConfig.shareInstance.cellTableViewDefaultHeight()
        self.bgView.snp.makeConstraints {[weak self] make in
            guard let self = self else { return }
            make.left.equalTo(self.messageAvatarsImageView.snp.right).offset(8)
            make.width.equalTo(VXIUIConfig.shareInstance.cellMaxWidth())
            make.top.equalTo(messageAvatarsImageView)
            make.height.equalTo(_h)
            make.bottom.equalTo(-VXIUIConfig.shareInstance.cellBottonContentMargin())
        }
        
        layoutIfNeeded()
    }
    
    //MARK: - 更新数据
    override func updateMessage(_ m: MessageModel, idx: IndexPath) {
        super.updateMessage(m, idx: idx)
        
        VXIUIConfig.shareInstance.cellMachineImage(ImageView: self.messageAvatarsImageView,
                                                   andSize: VXIUIConfig.shareInstance.cellUserImageSize())
        
        isNeedBubbleBackground = false
        messagebubbleBackImageView?.isHidden = true
        messageUserNameLabel.isHidden = true
        
        //加载数据
        self.dataArr = m.messageBody?.question_group
        
        layoutIfNeeded()
    }
    
    
    //MARK: - lazy load
    private lazy var bgView:UIView = {[unowned self] in
        let bgView = UIView()
        bgView.backgroundColor = .white
        bgView.layer.cornerRadius = VXIUIConfig.shareInstance.bubbleCornerRadius()
        
        bgView.addSubview(self.segmentedView)
        self.segmentedView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.equalTo(34)
        }
        
        bgView.addSubview(self.listContainerView)
        self.listContainerView.snp.remakeConstraints({[weak self] (make) in
            guard let self = self else { return }
            make.left.right.equalToSuperview()
            make.width.equalTo(VXIUIConfig.shareInstance.cellMaxWidth())
            make.top.equalTo(self.segmentedView.snp.bottom)
            make.bottom.equalTo(-40)
        })
        
        bgView.addSubview(self.changeView)
        changeView.snp.makeConstraints {[weak self] make in
            guard let self = self else { return }
            make.top.equalTo(self.listContainerView.snp.bottom)
            make.height.equalTo(40)
            make.left.right.bottom.equalToSuperview()
        }
        return bgView
    }()
    
    //MARK: 尾部视图
    private lazy var changeView:UIView = {[unowned self] in
        let v = UIView()
        v.backgroundColor = UIColor.white
        
        v.addSubview(self.btnChange)
        self.btnChange.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalTo(25)
            make.width.equalTo(100)
            make.right.equalTo(0)
        }
        return v
    }()
    
    private lazy var btnChange:UIButton = {
        let btn = TGSVerBtn()
        btn.setTitle("换一批", for: UIControl.State.normal)
        btn.setTitleColor(TGSUIModel.createColorHexInt(0x9E9E9E), for: UIControl.State.normal)
        btn.setImage(UIImage(named: "tool_change.png", in: VXIUIConfig.shareInstance.getBundle(), compatibleWith: nil), for: UIControl.State.normal)
        btn.imagePosition(style: TGSVerBtn.RGButtonImagePosition.left, spacing: 6.5)
        btn.rx.safeTap.subscribe {[weak self] event in
            guard let self = self else { return }
            self.clickChangeNew()
        }.disposed(by: rx.disposeBag)
        
        return btn
    }()
    
    //MARK: 分组面板
    private lazy var segmentedView:JXSegmentedView = {[unowned self] in
        let _v = JXSegmentedView.init(frame: .zero)
        _v.delegate = self
        _v.dataSource = self.titleDataSource
        _v.contentEdgeInsetLeft = 10
        _v.contentEdgeInsetRight = 16.5
        _v.isContentScrollViewClickTransitionAnimationEnabled = true
        _v.contentScrollView = self.listContainerView.scrollView
        
        //底部线
        let _line = TGSUIModel.createLable(rect: .zero,backgroundColor: VXIUIConfig.shareInstance.cellSplitColor())
        _v.addSubview(_line)
        _line.snp.makeConstraints { make in
            make.left.right.bottom.equalTo(0)
            make.height.equalTo(1)
        }
        
        ///初始化指示器indicator
        let indicator = JXSegmentedIndicatorLineView()
        indicator.isScrollEnabled = true
        indicator.indicatorColor = VXIUIConfig.shareInstance.cellHighlightColor()
        _v.indicators = [indicator]
        
        return _v
    }()
    
    private lazy var titleDataSource:JXSegmentedTitleDataSource = {
        let _ds = JXSegmentedTitleDataSource.init()
        
        //配置数据源相关属性
        _ds.isTitleColorGradientEnabled = false
        _ds.titleSelectedFont = UIFont.systemFont(ofSize: 14, weight: .regular)
        _ds.titleSelectedColor = VXIUIConfig.shareInstance.cellHighlightColor()
        _ds.titleNormalFont = UIFont.systemFont(ofSize: 14, weight: .regular)
        _ds.titleNormalColor = VXIUIConfig.shareInstance.cellnornalColor()
        _ds.itemSpacing = 20
        
        _ds.isItemSpacingAverageEnabled = false
        
        return _ds
    }()
    
    //MARK: 分组内容
    private lazy var listContainerView = JXSegmentedListContainerView(dataSource: self)
    
    /// 首页Index = 0
    private lazy var page_Index:Int = 0 {
        didSet{
            self.listContainerView.reloadData()
        }
    }
    
    /// 栏目索引
    private lazy var column_index:Int = 0 {
        didSet{
            //重置索引
            self.page_Index = 0
        }
    }
    
    private lazy var dataArr:[MessageQuestions]? = nil {
        didSet{
            var _arr = [String]()
            if self.dataArr != nil && (self.dataArr?.count ?? 0) > 0 {
                for _item in self.dataArr! where _item.name != nil && _item.name?.isEmpty == false {
                    _arr.append(_item.name!)
                }
            }
            
            self.titleDataSource.titles = _arr
            self.segmentedView.reloadData()
            self.listContainerView.reloadData()
        }
    }
}


//MARK: - 换一批
extension ChatMachineTabCell {
    
    /// 换一批
    private func clickChangeNew(){
        if (self.dataArr?.count ?? 0) > self.column_index {
            let _count:Int = self.dataArr![self.column_index].items.count
            let _page_count:Int = _count % self.page_size == 0 ? (_count / self.page_size) : (_count / self.page_size + 1)
            var _pi = self.page_Index + 1
            
            if _pi >= _page_count {
                _pi = 0//回到首页
            }
            debugPrint("总数据条数：\(_count),总页数：\(_page_count),页大小：\(self.page_size),当前页码：\(_pi)")
            
            self.page_Index = _pi
        }
    }
    
    /// 获取当前页数据
    private func getCurrentSizeData() -> [MessageGroupItems]? {
        self.btnChange.isHidden = true
        
        if (self.dataArr?.count ?? 0) > self.column_index {
            let _items = self.dataArr![self.column_index].items
            self.btnChange.isHidden = _items.count <= self.page_size
            
            var _endIndex = (self.page_Index + 1) * self.page_size
            if _items.count < _endIndex {
                _endIndex = _items.count
            }
            return Array(_items[(self.page_Index * self.page_size)..<_endIndex])
        }
        
        return nil
    }
}

//MARK: - JXSegmentedListContainerViewDataSource
extension ChatMachineTabCell : JXSegmentedListContainerViewDataSource {
    
    func numberOfLists(in listContainerView: JXSegmentedListContainerView) -> Int {
        self.titleDataSource.titles.count
    }
    
    func listContainerView(_ listContainerView: JXSegmentedListContainerView, initListAt index: Int) -> JXSegmentedListContainerViewListDelegate {
        
        let tv = ChatLoadDataViewController.init(frame: .zero,
                                                 style: .plain)
        tv.clickCellBlock = {[weak self] (_index,_item) in
            guard let self = self else { return }
            self.clickCellBlock?(_index,_item)
        }
        tv.arrList = self.getCurrentSizeData()
        return tv
    }
}

//MARK: - JXSegmentedViewDelegate
extension ChatMachineTabCell: JXSegmentedViewDelegate{
    
    func segmentedView(_ segmentedView: JXSegmentedView, didClickSelectedItemAt index: Int) {
        self.listContainerView.didClickSelectedItem(at: index)
    }
    
    // 点击或滚动选中调用该方法
    func segmentedView(_ segmentedView: JXSegmentedView, didSelectedItemAt index: Int) {
        //栏目切换
        self.column_index = index
    }
    
    func segmentedView(_ segmentedView: JXSegmentedView, scrollingFrom leftIndex: Int, to rightIndex: Int, percent: CGFloat) {
        self.listContainerView.scrolling(from: leftIndex, to: rightIndex, percent: percent, selectedIndex: segmentedView.selectedIndex)
    }
}


//MARK: - ChatLoadDataViewController
class ChatLoadDataViewController:UITableView {
    
    /// 点击回调
    public var clickCellBlock:((_ _selectedIndex:Int, _ _item:MessageGroupItems)->Void)?
    
    lazy var arrList:[MessageGroupItems]? = nil
    private let cellId = "ChatMachineListViewCell"
    
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        self.initView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initView(){
        //防止顶部空白
        if #available(iOS 11.0, *) {
            self.contentInsetAdjustmentBehavior = UIScrollView.ContentInsetAdjustmentBehavior.never
        }
        
        if #available(iOS 15.0, *) {
            self.sectionHeaderTopPadding = 0
        } else {
            // Fallback on earlier versions
        }
        
        self.register(ChatMachineListViewCell.self, forCellReuseIdentifier: cellId)
        self.rowHeight = UITableView.automaticDimension
        self.estimatedRowHeight = VXIUIConfig.shareInstance.cellTableViewDefaultHeight()
        self.delegate = self
        self.dataSource = self
        self.backgroundColor = UIColor.white
        self.bounces = false
        
        //分割线
        self.separatorStyle = .none
        self.separatorColor = VXIUIConfig.shareInstance.cellSplitColor()
        self.separatorInset = .zero
        
        self.layer.cornerRadius = VXIUIConfig.shareInstance.bubbleCornerRadius()
    }
}


extension ChatLoadDataViewController : JXSegmentedListContainerViewListDelegate {
    
    func listView() -> UIView {
        return self
    }
    
    func listDidAppear() {
        print("listDidAppear")
    }
    
    func listDidDisappear() {
        print("listDidDisappear-销毁了")
    }
}


//MARK: - UITableViewDelegate,UITableViewDataSource
extension ChatLoadDataViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrList?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return VXIUIConfig.shareInstance.cellTableViewDefaultHeight()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (self.arrList?.count ?? 0) > indexPath.row {
            self.clickCellBlock?(indexPath.row,self.arrList![indexPath.row])
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ChatMachineListViewCell
        
        if (self.arrList?.count ?? 0) > indexPath.row {
            let items = self.arrList![indexPath.row]
            cell.updateData(item: items, isHiddenLine: false)
        }
        cell.layoutIfNeeded()
        return cell
    }
}

