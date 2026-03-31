cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.260"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.260/agentshield_0.2.260_darwin_amd64.tar.gz"
      sha256 "d8e596147e77c010e79411d55fdc37d75413c4ccae38ccde82ea8790987b02b2"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.260/agentshield_0.2.260_darwin_arm64.tar.gz"
      sha256 "2fa0d4797ab1e68b5c73a8c92992ccea89ee59d97dd6b285e478946f5d6e58c2"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.260/agentshield_0.2.260_linux_amd64.tar.gz"
      sha256 "f6a401c9a4f90288c33a791d97257f71cfee6fd04f4f3352a4fda5ded32b2ba1"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.260/agentshield_0.2.260_linux_arm64.tar.gz"
      sha256 "c15e45b0d69cbe995ac857eedf8607abaaee363924b03a9cebaf28f434bb9380"
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
