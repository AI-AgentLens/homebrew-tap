cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2283"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2283/agentshield_0.2.2283_darwin_amd64.tar.gz"
      sha256 "7cc9eaddb22c49fae1d8fa701a76034f0be3206f792b8adc78ba318e59af91a6"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2283/agentshield_0.2.2283_darwin_arm64.tar.gz"
      sha256 "90264ac218d857370ad973a40cde53d9924298c932a968029da85eb5d1707368"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2283/agentshield_0.2.2283_linux_amd64.tar.gz"
      sha256 "d79b2f3e91b726c9107a8d79e9856ab0a73a3c4f7c431a120db210c7d91f8862"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2283/agentshield_0.2.2283_linux_arm64.tar.gz"
      sha256 "f9188cca08be81971f147f3b9b32ed7685e138cdafdea501f7c674437424501c"
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
