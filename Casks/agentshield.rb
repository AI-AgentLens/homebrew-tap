cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1375"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1375/agentshield_0.2.1375_darwin_amd64.tar.gz"
      sha256 "8345937960b648bb1c45b7effabfa7d84f05fb122831fecb31bda39d53bc2a12"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1375/agentshield_0.2.1375_darwin_arm64.tar.gz"
      sha256 "0d4248030768935ed927eb9beaaf04f7de76716f3a3aeb61d7792695f41a2fda"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1375/agentshield_0.2.1375_linux_amd64.tar.gz"
      sha256 "8d8600f4cb1b876673489574cfa25de4851da224a40ed593f86a27aa5f452f53"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1375/agentshield_0.2.1375_linux_arm64.tar.gz"
      sha256 "ee875934ccd894c82b58abaaaf5ca17dbe0d5f82a0f744978d2d00b9e16f0691"
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
