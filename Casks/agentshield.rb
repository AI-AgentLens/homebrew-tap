cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1176"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1176/agentshield_0.2.1176_darwin_amd64.tar.gz"
      sha256 "8f33f8c29c6b330fce5030b18da76565bacb603447c70b4362d1b278ec7239d0"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1176/agentshield_0.2.1176_darwin_arm64.tar.gz"
      sha256 "d058751344221022304b5e0a3b60de01dbef3379ed4a3d8689cbf53652e944e5"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1176/agentshield_0.2.1176_linux_amd64.tar.gz"
      sha256 "bb521db3842e16fa6924d95045c97416197a885027e729a66b72a943e349f269"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1176/agentshield_0.2.1176_linux_arm64.tar.gz"
      sha256 "6406b381443724c6126b8d9d8f2407d6c09ba0f9503256b2f88cd39f87546c0a"
    end
  end

  # Stop the heartbeat daemon before upgrading so the old binary doesn't keep
  # running as a zombie after brew replaces it.
  preflight do
    if OS.mac?
      plist = File.expand_path("~/Library/LaunchAgents/com.aiagentlens.agentshield.plist")
      if File.exist?(plist)
        system_command "/bin/launchctl", args: ["bootout", "gui/#{Process.uid}/com.aiagentlens.agentshield"], print_stderr: false
        File.delete(plist) if File.exist?(plist)
      end
    end
  end

  postflight do
    if OS.mac?
      system_command "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "#{staged_path}/agentshield"]
      system_command "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "#{staged_path}/agentcompliance"]
    end
  end

  uninstall launchctl: "com.aiagentlens.agentshield",
            delete:    "~/Library/LaunchAgents/com.aiagentlens.agentshield.plist"

  caveats <<~EOS
    Two tools installed:
      agentshield      — Runtime security gateway for AI agents
      agentcompliance  — Local compliance scanner (semgrep-based)

    Quick start:
      agentshield setup
      agentshield login
  EOS
end
