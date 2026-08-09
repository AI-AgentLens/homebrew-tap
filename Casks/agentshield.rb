cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1804"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1804/agentshield_0.2.1804_darwin_amd64.tar.gz"
      sha256 "68144adfb01a19d62342153a45250a193a9a24d0c3004efb5183a69875f74ffb"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1804/agentshield_0.2.1804_darwin_arm64.tar.gz"
      sha256 "6983a1ce177750a2c204c04422a9885fb7e0d986eb20d0e26c7cb81cabc1a678"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1804/agentshield_0.2.1804_linux_amd64.tar.gz"
      sha256 "0c46f8c4c205de13c8e43b77b9016e363fe5f0cc10ca0e7eccd17bf9713280f3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1804/agentshield_0.2.1804_linux_arm64.tar.gz"
      sha256 "0e56e65b07e71d33fd5d4773d62d5173a67deb2b3a3c19a7b4a94881738474f6"
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
