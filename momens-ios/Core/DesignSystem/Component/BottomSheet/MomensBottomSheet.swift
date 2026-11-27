import SwiftUI

extension View {
    func momensBottomSheet(
        isPresented: Binding<Bool>,
        showsDragHandle: Bool = true,
        @ViewBuilder content: @escaping () -> some View
    ) -> some View {
        modifier(
            MomensBottomSheetModifier(
                isPresented: isPresented,
                showsDragHandle: showsDragHandle,
                sheetContent: content
            )
        )
    }
}

private struct MomensBottomSheetModifier<SheetContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    let showsDragHandle: Bool
    @ViewBuilder let sheetContent: () -> SheetContent

    @State private var sheetHeight: CGFloat = 0

    private var detents: Set<PresentationDetent> {
        sheetHeight > 0 ? [.height(sheetHeight)] : [.medium]
    }

    private static func clearFocus() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }

    func body(content: Content) -> some View {
        content.sheet(isPresented: $isPresented) {
            sheetContent()
                .frame(maxWidth: .infinity)
                .padding(.top, showsDragHandle ? MomensDragHandle.height : 0)
                .contentShape(.rect)
                .onTapGesture {
                    Task { @MainActor in
                        Self.clearFocus()
                    }
                }
                .onGeometryChange(
                    for: CGFloat.self,
                    of: { $0.size.height + $0.safeAreaInsets.bottom },
                    action: { sheetHeight = $0 }
                )
                .presentationDetents(detents)
                .presentationDragIndicator(.hidden)
                .presentationCornerRadius(20)
                .presentationBackground(alignment: .top) {
                    ZStack(alignment: .top) {
                        MomensColor.white

                        if showsDragHandle {
                            MomensDragHandle()
                        }
                    }
                }
        }
    }
}

private struct MomensDragHandle: View {
    static let height: CGFloat = 35

    var body: some View {
        Capsule()
            .fill(MomensColor.gray100)
            .frame(width: 73, height: 3)
            .padding(.vertical, 16)
    }
}

private struct MomensBottomSheetPreview: View {
    @State private var isPresented = true

    var body: some View {
        MomensColor.uiBackground
            .ignoresSafeArea()
            .momensBottomSheet(isPresented: $isPresented) {
                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: 6) {
                        Text("PM")
                            .foregroundStyle(MomensColor.gray400)
                            .momensFont(.captionM11)

                        Circle()
                            .fill(MomensColor.gray500)
                            .frame(width: 2, height: 2)

                        Text("Copy policy")
                            .foregroundStyle(MomensColor.gray400)
                            .momensFont(.captionM11)
                    }

                    Text("회원가입 에러 메시지 정책 초안")
                        .foregroundStyle(MomensColor.gray900)
                        .momensFont(.bodyB16)

                    Text("회원가입의 MVP 완료율과 온보딩 품질에 영향을 줄 수 있습니다.")
                        .foregroundStyle(MomensColor.gray400)
                        .momensFont(.bodyM12)
                        .padding(.top, 16)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
            }
    }
}

#Preview("MomensBottomSheet") {
    MomensBottomSheetPreview()
}
