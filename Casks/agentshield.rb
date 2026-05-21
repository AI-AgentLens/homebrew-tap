cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1050"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1050/agentshield_0.2.1050_darwin_amd64.tar.gz"
      sha256 "2b9ae0359f09426951f1c61064257bfbde2d1e92fd5c80075f123d22823aafac"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1050/agentshield_0.2.1050_darwin_arm64.tar.gz"
      sha256 "e7a82bbf0186820325a8e1528a6ce94c8fd241e482e6824888969594e972eee8"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1050/agentshield_0.2.1050_linux_amd64.tar.gz"
      sha256 "3d5b8efe30e223843e35ca9cde6a51f4cd1c21463a313fd342faebc0880e3b03"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1050/agentshield_0.2.1050_linux_arm64.tar.gz"
      sha256 "06f3a307bd10b506ea2526ce3a38220d72de03efc6fff7975488aff22443ce29"
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
