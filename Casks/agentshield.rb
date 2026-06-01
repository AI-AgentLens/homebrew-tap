cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1186"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1186/agentshield_0.2.1186_darwin_amd64.tar.gz"
      sha256 "2912e07bced9fd347e97c09df1b0e3c1b843e262b67913b787f5b48f36394a03"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1186/agentshield_0.2.1186_darwin_arm64.tar.gz"
      sha256 "63fd2981042fd0892d65c5e90f80a3e27785cadc19aac1cf5894e0889c849a54"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1186/agentshield_0.2.1186_linux_amd64.tar.gz"
      sha256 "256b1f36db7c31dfa79a321914a5dbeb5c3d5fcf0a98f373e33553e80812eb6f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1186/agentshield_0.2.1186_linux_arm64.tar.gz"
      sha256 "53f79c09e7f8d72beaec1f0b4d519cc990129ef5fd6ecf46f63393f64b9a4788"
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
