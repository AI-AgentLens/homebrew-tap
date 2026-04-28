cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.782"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.782/agentshield_0.2.782_darwin_amd64.tar.gz"
      sha256 "e0959b2b684c41f1d97f76d7b4268ff848a734fb969ec28432f325b7202efab9"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.782/agentshield_0.2.782_darwin_arm64.tar.gz"
      sha256 "f482264cf36cecb86894dc9ae293bed8cf1ae452a0b7fdf630ba52cd450c285c"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.782/agentshield_0.2.782_linux_amd64.tar.gz"
      sha256 "f86d46baed0e38395996ada1904eb7cdc741a74c6c888381e9a111dffb1bb526"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.782/agentshield_0.2.782_linux_arm64.tar.gz"
      sha256 "1441f462723e5a23c08d0d47147bfb22c8c6ef21ff4aea5a6516f2419929291d"
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
