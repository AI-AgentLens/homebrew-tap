cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.855"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.855/agentshield_0.2.855_darwin_amd64.tar.gz"
      sha256 "d1f639695b2b336a3ed398dbf2097eccadf4d1619d321ac1843411f8a8d4f2fd"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.855/agentshield_0.2.855_darwin_arm64.tar.gz"
      sha256 "4b1a8593b9df1031172ec23510ff7f2aab10f65867d20bd07100fd189cac692a"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.855/agentshield_0.2.855_linux_amd64.tar.gz"
      sha256 "11f5851c64ef20a3c485945b5bd7744100a91d94a9d8739991b80c014cbc7969"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.855/agentshield_0.2.855_linux_arm64.tar.gz"
      sha256 "2cbf4aea813c2d09f517b9d0fbd19ee1333dbf7a57410ce0168c86020c71f24a"
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
