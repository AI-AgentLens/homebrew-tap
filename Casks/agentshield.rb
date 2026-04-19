cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.652"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.652/agentshield_0.2.652_darwin_amd64.tar.gz"
      sha256 "eafa7566df44e6d0273618455cf726367906b02ba2cf3f6ac731a77264963836"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.652/agentshield_0.2.652_darwin_arm64.tar.gz"
      sha256 "8a36d9bcc929091a221513a776c01b8473db818424675e5e8507029c0eb0b719"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.652/agentshield_0.2.652_linux_amd64.tar.gz"
      sha256 "a6eda6d301a0516cdcd8dd43174b13c8e436b7f5a47ff07928dda9095239962a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.652/agentshield_0.2.652_linux_arm64.tar.gz"
      sha256 "0d1e6afc6942974e13df2653f6306b1251330128de92a1f9d3d2fb56d9485092"
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
