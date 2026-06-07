cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1236"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1236/agentshield_0.2.1236_darwin_amd64.tar.gz"
      sha256 "49f448f19a2d01c21acb293dde24b7556e89740d6d3d9ac623722cbfe8636c8d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1236/agentshield_0.2.1236_darwin_arm64.tar.gz"
      sha256 "7132bd9efde9366dc8931af53abdb336866332d0475b7a5de79302ceaf643aa4"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1236/agentshield_0.2.1236_linux_amd64.tar.gz"
      sha256 "61c60decfcf91f20aefcb18a6c76ac55fede43b6ca92b04d2efeb25c8f4336c7"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1236/agentshield_0.2.1236_linux_arm64.tar.gz"
      sha256 "dd6f91689947073a9137ce6c8ec16e21117966397d809220b83e602374586ea0"
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
