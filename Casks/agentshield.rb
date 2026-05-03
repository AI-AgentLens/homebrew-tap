cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.864"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.864/agentshield_0.2.864_darwin_amd64.tar.gz"
      sha256 "bf4397a90ed2424abe0fbe85dc01f088900edd47d74284bf3f044e28f7beead2"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.864/agentshield_0.2.864_darwin_arm64.tar.gz"
      sha256 "c9c80e9fcf5a83013791a37c1e9778d38b8381d37c9a4b2b23f6861416948504"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.864/agentshield_0.2.864_linux_amd64.tar.gz"
      sha256 "787a2942e8df45c518cafad75438ac7f1be96be53043a7096e5adb18c9477c83"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.864/agentshield_0.2.864_linux_arm64.tar.gz"
      sha256 "3c6cf4da8e663b01133111b23e2b19df746815c1f84fbe3201c79731874f9a8b"
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
