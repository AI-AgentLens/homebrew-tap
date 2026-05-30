cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1157"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1157/agentshield_0.2.1157_darwin_amd64.tar.gz"
      sha256 "6f264613cb3a8d14ee74d6d2b7ff741019c1d5ee9db5cf4206c4d317e5a47ca0"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1157/agentshield_0.2.1157_darwin_arm64.tar.gz"
      sha256 "083681561b51df6809bea25c00aaf0a2933332f8a4ba2583c13082e6bd941a26"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1157/agentshield_0.2.1157_linux_amd64.tar.gz"
      sha256 "9d9393059a6708beb87d5648ba20cb11809c887e088dcf56b259c51d10a536a6"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1157/agentshield_0.2.1157_linux_arm64.tar.gz"
      sha256 "084cc06dcb43f26573227b60e123b7813ae544d6ee246ec1ff7e7dfaa7a3a6de"
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
