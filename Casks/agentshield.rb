cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2028"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2028/agentshield_0.2.2028_darwin_amd64.tar.gz"
      sha256 "797c27746c792914a7a94c7f7da5c00419530fe5615aa45b78f61b870867a0a1"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2028/agentshield_0.2.2028_darwin_arm64.tar.gz"
      sha256 "3dd2637c869ec267801ceb16805e6ecf2d8c9d1c33598b4253e6aa3785b23fb1"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2028/agentshield_0.2.2028_linux_amd64.tar.gz"
      sha256 "9ae816c6f17606113ef92fceda2fc94c83bdad25113ae04b956653dbe9aa7494"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2028/agentshield_0.2.2028_linux_arm64.tar.gz"
      sha256 "34566f0f24e9d589a7d6f7505a9b11a87032da0c6bf48f38a9490873a284aca5"
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
