cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1199"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1199/agentshield_0.2.1199_darwin_amd64.tar.gz"
      sha256 "19d1a3f0613a6324735f8b9b60f1682ff0207daf0beba91ef0e24db2132cb973"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1199/agentshield_0.2.1199_darwin_arm64.tar.gz"
      sha256 "559fc596c8e9e38067174b54986aab53f10d685622f4fc09704af4f298668e27"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1199/agentshield_0.2.1199_linux_amd64.tar.gz"
      sha256 "46268d3f25596a5c2ae22c92c6542224c932f6621936005488f6ae3460ef632e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1199/agentshield_0.2.1199_linux_arm64.tar.gz"
      sha256 "9232e2cecf9592277779363414086cbb2963bd435288dfd55fd879f65a53ddf1"
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
